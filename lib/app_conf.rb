require 'yaml'

class AppConf
  def initialize
    @hash = {}
  end
  @@root = new

  def self.load(*filenames)
    filenames.each do |filename|
      from_hash(YAML.load(File.open(filename)))
    end
  end

  def self.save(key, filename)
    mode = File.exist?(filename) ? 'r+' : 'w+'
    File.open(filename, mode) do |f|
      while f.readline =~ /^#/; end unless f.eof?
      hash = {key.to_s => @@root[key].to_hash}
      YAML.dump(hash, f)
      f.truncate(f.pos)
    end
  end

  def self.clear
    @@root = new
    nil
  end

  def self.to_hash
    @@root.to_hash
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

  def self.method_missing(method, *args, &block)
    @@root.send(method, *args)
  end

  def self.from_hash(hash, app_config = @@root)
    hash.each do |key, value|
      if value.is_a?(Hash)
        new_app_config = new
        value = from_hash(value, app_config[key] || new_app_config)
      end
      app_config[key] = value if new_app_config.nil? || value === new_app_config
    end
    app_config
  end
end

