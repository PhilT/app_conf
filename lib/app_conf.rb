require 'yaml'

class AppConf
  attr_reader :config

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

  def method_missing(method, *args, &block)
    method = method.to_s
    if method[-1] == '='
      method = method[0..-2]
      raise "Not allowed to overwrite nested entities" if @config[method].is_a?(AppConf)
      @config[method] = args.first
    else
      @config[method]
    end
  end

  def self.method_missing(method, *args, &block)
    @@config.send(method, *args)
  end

private
  def self.recurse(yaml, app_config)
    yaml.each do |k, v|
      v = recurse(v, app_config.send(k) || new) if v.is_a?(Hash)
      app_config.config[k] = v
    end
    app_config
  end
end

