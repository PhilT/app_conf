gem 'minitest', require: 'minitest/autorun'
gem 'fakefs', require: 'fakefs/safe'

require 'fakefs/safe'
require 'minitest/autorun'
require_relative '../lib/app_conf'

module MiniTest
  module Assertions
    alias :actual_diff :diff

    # Stop FakeFS interfering with saving multiline diffs
    def diff exp, act
      FakeFS.without do
        actual_diff exp, act
      end
    end
  end
end

describe AppConf do
  before do
    FakeFS.activate!
    FakeFS::FileSystem.clear

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
    File.open('other.yml', 'w') {|f| f.write(other) }
    $conf = AppConf.new
    $conf.load("config.yml")
  end

  after do
    FakeFS.deactivate!
  end

  it 'returns nil on empty tree' do
    $conf.clear
    $conf.user.must_be_nil
  end

  it 'clears a key' do
    $conf.user.clear :name
    $conf.user.name.must_be_nil
  end

  it 'clears a key in root' do
    $conf.clear :user
    $conf.user.must_be_nil
  end

  it 'cleared key can be overwritten' do
    $conf.clear :user
    $conf.user = 'something'
    $conf.user.must_equal 'something'
  end

  it 'handles rake clobbering global' do
    $conf.task = 'something'
    $conf.task.must_equal 'something'
  end

  describe 'save' do
    it 'saves a key and children to yml' do
      $conf.save :user, 'temp.yml'
      YAML.load_file('temp.yml').must_equal({'user' => {'name' => {'first' => 'Joe'}}})
    end

    it 'skips past comments' do
      File.open('config.yml', 'w') {|f| f.write("# comment 1\n# comment 2\n\n---\nRest of the config")}
      $conf.save :user, 'config.yml'
      File.read('config.yml').must_equal "# comment 1\n# comment 2\n\n---\nuser:\n  name:\n    first: Joe\n"
    end

    it 'overwrites when no --- and single line' do
      File.open('config.yml', 'w') {|f| f.write("some config\n") }
      $conf.save :user, 'config.yml'
      File.read('config.yml').must_equal "---\nuser:\n  name:\n    first: Joe\n"
    end

    it 'overwrites when no --- and multiline' do
      File.open('config.yml', 'w') {|f| f.write("# Some\n# comments\n\nconfig:\n  name:\n") }
      $conf.save :user, 'config.yml'
      File.read('config.yml').must_equal "---\nuser:\n  name:\n    first: Joe\n"
    end
  end

  describe 'to_hash' do
    it 'outputs a hash map' do
      $conf.load("other.yml")
      $conf.to_hash.must_equal({'fullname' => 'Joe Bloggs', 'user' => {'name' => {'first' => 'Joe'}, 'address' => {'street' => '1 Some Road'}}})
    end
  end

  describe 'keys' do
    it 'returns them' do
      $conf.from_hash(:users => {:joe => nil, :mark => nil})

      $conf.users.keys.must_equal %w(joe mark)
    end
  end

  it 'creates from a hash' do
    $conf.clear
    $conf.from_hash(:user => {:name => {:first => 'Joe'}})
    $conf.user.name.first.must_equal 'Joe'
  end

  it 'works with dot notation' do
    $conf.fullname.must_equal 'Joe Bloggs'
  end

  it 'works with hash notation' do
    $conf[:fullname].must_equal 'Joe Bloggs'
    $conf['fullname'].must_equal 'Joe Bloggs'
  end

  describe 'clear' do
    it 'clears all keys' do
      $conf.fullname.wont_be_nil
      $conf.clear
      $conf.fullname.must_be_nil
    end

    it 'does not return $conf instance' do
      $conf.clear.must_be_nil
    end
  end

  it 'works with nested dot notation' do
    $conf.user.name.first.must_equal 'Joe'
  end

  it 'works with nested hash notation' do
    $conf[:user][:name][:first].must_equal 'Joe'
    $conf['user']['name']['first'].must_equal 'Joe'
  end

  it 'works with mixed notation' do
    $conf[:user][:name][:first].must_equal 'Joe'
    $conf.user['name'].first.must_equal 'Joe'
  end

  it 'works with multiple files' do
    $conf.clear
    $conf.load("config.yml", "other.yml")
    $conf.user.address.street.must_equal '1 Some Road'
    $conf.user.name.first.must_equal 'Joe'
  end

  it 'loads additional files' do
    $conf.load("other.yml")
    $conf.user.address.street.must_equal '1 Some Road'
    $conf.user.name.first.must_equal 'Joe'
  end

  it 'allows additional keys to be set' do
    $conf.user.name.last = 'Bloggs'
    $conf.user.name.last.must_equal 'Bloggs'
  end

  it 'allows additional keys to be set with hash notation' do
    $conf.user[:name][:last] = 'Bloggs'
    $conf.user.name.last.must_equal 'Bloggs'
  end

  it 'allows existing keys to be overridden' do
    $conf.user.name.first = 'Jody'
    $conf.user.name.first.must_equal 'Jody'
  end

  describe 'limitations' do
    it 'returns nil when unknown key specified' do
      $conf.unknown.must_be_nil
    end

    it 'does not allow nested items to be overwritten' do
      lambda { $conf.user.name = 'something' }.must_raise RuntimeError
      lambda { $conf[:user][:name] = 'something' }.must_raise RuntimeError
    end
  end
end

