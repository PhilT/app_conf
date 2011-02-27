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

  def method_missing(method, *args, &block)
    method = method.to_s
    method = args.delete_at(0).to_s if method == '[]'
    method = args.delete_at(0).to_s + '=' if method == '[]='
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
  def self.recurse(hash, app_config)
    hash.each do |key, value|
      if value.is_a?(Hash)
        new_app_config = new
        value = recurse(value, app_config.send(key) || new_app_config)
      end
      app_config.send("#{key}=", value) if new_app_config.nil? || value === new_app_config
    end
    app_config
  end
end

