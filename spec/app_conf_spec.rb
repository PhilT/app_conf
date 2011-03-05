$LOAD_PATH << 'lib'
require 'minitest/autorun'
require 'app_conf'

describe AppConf do
  before(:each) do
    @dir = File.dirname(__FILE__)
    AppConf.clear
    AppConf.load("#{@dir}/config.yml")
  end

  it 'creates from a hash' do
    AppConf.clear
    AppConf.from_hash({:user => {:name => {:first => 'Joe'}}})
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'works with dot notation' do
    AppConf.fullname.must_equal 'Joe Bloggs'
  end

  it 'works with hash notation' do
    AppConf[:fullname].must_equal 'Joe Bloggs'
    AppConf['fullname'].must_equal 'Joe Bloggs'
  end

  describe 'clear' do
    it 'clears all keys' do
      AppConf.fullname.wont_be_nil
      AppConf.clear
      AppConf.fullname.must_be_nil
    end

    it 'does not return AppConf instance' do
      AppConf.clear.must_be_nil
    end
  end

  it 'works with nested dot notation' do
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'works with nested hash notation' do
    AppConf[:user][:name][:first].must_equal 'Joe'
    AppConf['user']['name']['first'].must_equal 'Joe'
  end

  it 'works with mixed notation' do
    AppConf[:user][:name][:first].must_equal 'Joe'
    AppConf.user['name'].first.must_equal 'Joe'
  end

  it 'works with multiple files' do
    AppConf.clear
    AppConf.load("#{@dir}/config.yml", "#{@dir}/other.yml")
    AppConf.user.address.street.must_equal '1 Some Road'
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'loads additional files' do
    AppConf.load("#{@dir}/other.yml")
    AppConf.user.address.street.must_equal '1 Some Road'
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'allows additional keys to be set' do
    AppConf.user.name.last = 'Bloggs'
    AppConf.user.name.last.must_equal 'Bloggs'
  end

  it 'allows additional keys to be set with hash notation' do
    AppConf.user[:name][:last] = 'Bloggs'
    AppConf.user.name.last.must_equal 'Bloggs'
  end

  it 'allows existing keys to be overridden' do
    AppConf.user.name.first = 'Jody'
    AppConf.user.name.first.must_equal 'Jody'
  end

  describe 'limitations' do
    it 'returns nil when unknown key specified' do
      AppConf.unknown.must_be_nil
    end

    it 'does not allow nested items to be overwritten' do
      lambda { AppConf.user.name = 'something' }.must_raise RuntimeError
      lambda { AppConf[:user][:name] = 'something' }.must_raise RuntimeError
    end
  end
end

