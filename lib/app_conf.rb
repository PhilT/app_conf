require 'yaml'

class AppConf
  @@root = new

  def initialize
    @hash = {}
  end

  def self.load(*filenames)
    filenames.each do |filename|
      from_hash(YAML.load(File.open(filename)))
    end
  end

  def self.clear
    @@root = new
    nil
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

