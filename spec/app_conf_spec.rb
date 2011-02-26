$LOAD_PATH << 'lib'
require 'app_conf'

describe AppConf do
  before(:each) do
    @dir = File.dirname(__FILE__)
  end

  it 'works with dot notation' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.fullname.should == 'Joe Bloggs'
  end

  it 'works with nested dot notation' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.user.name.first.should == 'Joe'
  end

  it 'works with multiple files' do
    AppConf.load("#{@dir}/config.yml", "#{@dir}/other.yml")
    AppConf.user.address.street.should == '1 Some Road'
    AppConf.user.name.first.should == 'Joe'
  end

  it 'allows additional keys to be set' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.user.name.last = 'Bloggs'
    AppConf.user.name.last.should == 'Bloggs'
  end

  it 'allows existing keys to be overridden' do
    AppConf.load("#{@dir}/config.yml")
    AppConf.user.name.first = 'Jody'
    AppConf.user.name.first.should == 'Jody'
  end

  it 'cannot instantiate' do
    expect { AppConf.new }.to raise_error('AppConf is not meant to be instantiated.')
  end
end

