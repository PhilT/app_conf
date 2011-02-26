require 'ostruct'
require 'yaml'

class AppConf
  def initialize
    raise 'AppConf is not meant to be instantiated.'
  end


  def self.load(*filenames)
    @@config = OpenStruct.new
    filenames.each do |filename|
      recurse(YAML.load(File.open(filename)), @@config)
    end
  end

  def self.method_missing(method, *args, &block)
    @@config.send(method, *args)
  end

private
  def self.recurse(yaml, struct)
    yaml.each do |k, v|
      v = recurse(v, struct.send(k) || OpenStruct.new) if v.is_a?(Hash)
      struct.send("#{k}=", v)
    end
    struct
  end
end

