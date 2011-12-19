$LOAD_PATH << 'lib'
require 'fakefs/safe'
require 'minitest/autorun'
require 'app_conf'

describe AppConf do
  before(:each) do
    FakeFS.activate!

    config = 
"fullname: Joe Bloggs
user:
  name:
    first: Joe
"
    other =
"user:
  address:
      street: 1 Some Road
"
    File.open('config.yml', 'w') {|f| f.write(config) }
    File.open('other.yml', 'w') {|f| f.write(other)}
    AppConf.clear
    AppConf.load("config.yml")
  end

  after(:each) do
    FakeFS.deactivate!
  end

  it 'returns nil on empty tree' do
    AppConf.clear
    AppConf.user.must_be_nil
  end

  describe 'save' do
    it 'saves a key and children to yml' do
      AppConf.save :user, 'temp.yml'
      YAML.load_file('temp.yml').must_equal({'user' => {'name' => {'first' => 'Joe'}}})
    end

    it 'skips past comments' do
      File.open('config.yml', 'w') {|f| f.write("# comment 1\n# comment 2\n\n--- \nRest of the config")}
      AppConf.save :user, 'config.yml'
      File.read('config.yml').must_equal "# comment 1\n# comment 2\n\n--- \nuser: \n  name: \n    first: Joe\n"
    end

    it 'overwrites when no ---' do
      File.open('config.yml', 'w') {|f| f.write('some config') }
      AppConf.save :user, 'config.yml'
      File.read('config.yml').must_equal "--- \nuser: \n  name: \n    first: Joe\n"
    end
  end

  describe 'to_hash' do
    it 'outputs a hash map' do
      AppConf.load("other.yml")
      AppConf.to_hash.must_equal({'fullname' => 'Joe Bloggs', 'user' => {'name' => {'first' => 'Joe'}, 'address' => {'street' => '1 Some Road'}}})
    end
  end

  describe 'keys' do
    it 'returns them' do
      AppConf.from_hash(:users => {:joe => nil, :mark => nil})

      AppConf.users.keys.must_equal %w(joe mark)
    end
  end

  it 'creates from a hash' do
    AppConf.clear
    AppConf.from_hash(:user => {:name => {:first => 'Joe'}})
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
    AppConf.load("config.yml", "other.yml")
    AppConf.user.address.street.must_equal '1 Some Road'
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'loads additional files' do
    AppConf.load("other.yml")
    AppConf.user.address.street.must_equal '1 Some Road'
    AppConf.user.name.first.must_equal 'Joe'
  end

  it 'handles empty files' do
    File.open('empty.yml', 'w') {}
    AppConf.load('empty.yml')
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

