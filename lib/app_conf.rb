require 'yaml'

class AppConf
  private_class_method :new
  def initialize
    @config = {}
  end
  @@config = new

  def self.load(*filenames)
    filenames.each do |filename|
      recurse(YAML.load(File.open(filename)), @@config)
    end
  end

  def self.clear
    @@config = new
    nil
  end

  def [](key)
    @config[key.to_s]
  end

  def []=(key, value)
    raise "Not allowed to overwrite nested entities" if @config[key.to_s].is_a?(AppConf)
    @config[key.to_s] = value
  end

  def method_missing(method, *args, &block)
    if method[-1] == '='
      self[method[0..-2]] = args.first
    else
      self[method]
    end
  end

  def self.method_missing(method, *args, &block)
    @@config.send(method, *args)
  end

private
  def self.recurse(hash, app_config)
    hash.each do |key, value|
      if value.is_a?(Hash)
        new_app_config = new
        value = recurse(value, app_config[key] || new_app_config)
      end
      app_config[key] = value if new_app_config.nil? || value === new_app_config
    end
    app_config
  end
end

