$LOAD_PATH << 'lib'
require 'minitest/autorun'
require 'app_conf'

describe AppConf do
  before(:each) do
    @dir = File.dirname(__FILE__)
  end

  it 'cannot be instantiated directly' do
    AppConf.new.must_be_nil
  end

  it 'works with dot notation' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.fullname.must_equal 'Joe Bloggs'
  end

  it 'works with nested dot notation' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'works with multiple files' do
    AppConf.load("#{@dir}/config.yml", "#{@dir}/other.yml")
    AppConf.user.address.street.must_equal '1 Some Road'
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'allows additional keys to be set' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.user.name.last = 'Bloggs'
    AppConf.user.name.last.must_equal 'Bloggs'
  end

  it 'allows existing keys to be overridden' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.user.name.first = 'Jody'
    AppConf.user.name.first.must_equal 'Jody'
  end

  it 'does not allow nested items to be overwritten' do
    AppConf.load("#{@dir}/config.yml")
    lambda { AppConf.user.name = 'something' }.must_raise RuntimeError
  end

end

