require 'yaml'

# Stop warning showing when used with SafeYAML
SafeYAML::OPTIONS[:default_mode] = :safe if defined?(SafeYAML)

class AppConf
  def initialize
    @hash = {}
  end

  def load(*filenames)
    filenames.each do |filename|
      content = YAML.load_file(filename)
      from_hash(content) if content
    end
  end

  def save(key, filename)
    mode = File.exist?(filename) ? 'r+' : 'w+'
    File.open(filename, mode) do |f|
      unless f.eof?
        begin
          pos = f.pos
          line = f.readline
        end until line =~ /^---/ || f.eof?
        line =~ /^---/ ? f.seek(pos) : f.rewind
      end
      hash = {key.to_s => self[key].to_hash}
      YAML.dump(hash, f)
      f.truncate(f.pos)
    end
  end

  def clear key = nil
    key ? @hash[key.to_s] = nil : @hash = {}
    nil
  end

  def to_hash
    hash = {}
    @hash.each {|k, v| hash[k] = v.is_a?(AppConf) ? v.to_hash : v }
    hash
  end

  def keys
    @hash.keys
  end

  def [](key)
    value = @hash[key.to_s]
  end

  def []=(key, value)
    raise "Not allowed to overwrite nested entities" if @hash[key.to_s].is_a?(AppConf)
    @hash[key.to_s] = value
  end

  def method_missing(method, *args, &block)
    if method[-1] == '='
      self[method[0..-2]] = args.first
    else
      self[method]
    end
  end

  def from_hash(hash)
    hash.each do |key, value|
      value = (self[key] || AppConf.new).from_hash(value) if value.is_a?(Hash)
      @hash[key.to_s] = value
    end
    self
  end
end

