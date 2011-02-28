AppConf
=======
Simplest YAML Backed Application Wide Configuration (AppConfig)

Installation
----------------------------------
    gem install app_conf

Example
----------------------------------
config.yml
    ---
    fullname: Joe Bloggs
    user:
      name: Joe

other.yml
    ---
    user:
      address:
        street: 1 Some Road

Code:
    AppConf.load('config.yml', 'other.yml')
    AppConf.fullname -> 'Joe Blogs'
    AppConf.user.name -> 'Joe'
    AppConf.user[:address]['street'] -> '1 Some Road'

Syntax
----------------------------------
Load multiple files at once:
    AppConf.load(*filenames)

Or individually:
    AppConf.load(filename1)
    AppConf.load(filename2)

Use either method calls or hash syntax:
    AppConf.fullname
    AppConf[:fullname]
    AppConf['fullname']

Infinitely nested keys:
    AppConf.multiple.nested.keys

Override existing values:
    AppConf.loaded.from.yaml = 'can override'
    AppConf['loaded']['from']['yaml'] = 'can override'

Set new values:
    AppConf.non_existing_value = 'can set'

Clear entire tree:
    AppConf.clear

Returns nil for non-existent keys:
    AppConf.non_existing -> nil
    AppConf.non_existing.name -> NoMethodError: undefined method 'name' for nil:NilClass

Not dependent on Rails but easy to use with it. For example:
    AppConf.load('config.yml', "#{Rails.env}.yml")

Other stuff
----------------------------------
* Works with Ruby 1.9.2
* No gem dependencies
* Fully tested with MiniTest::Spec
* Packaged as a Gem on RubyGems.org

Why
----------------------------------
* Because I wanted to write the simplest useful app config possible
* Others are either too simple or incomplete, lack documentation or aren't Gem installable
* Because I can :-)

Known Issues
----------------------------------
Cannot assign values to unknown nested keys because they return nil
    AppConf.non_existing.name = 'bla' -> NoMethodError: undefined method 'name=' for nil:NilClass

