AppConf
----------------------------------

YAML Backed Application Wide Configuration with a few extras

(AppConfig like)

* Supports nested key/values
* Loading and Saving of YAML files
* Add further key/value pairs in code
* Use dot or bracket notation
* `AppConf#to_hash` outputs a hash map of AppConf key/values
* `AppConf#from_hash` creates nested key/values from a hash

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

    $conf = AppConf.new

    $conf.load('config.yml', 'other.yml')
    $conf.fullname -> 'Joe Blogs'
    $conf.user.name -> 'Joe'
    $conf.user[:address]['street'] -> '1 Some Road'

Syntax
----------------------------------

Load multiple files at once:

    $conf.load(*filenames)

Or individually:

    $conf.load(filename1)
    $conf.load(filename2)

Use either method calls or hash syntax:

    $conf.fullname
    $conf[:fullname]
    $conf['fullname']

Infinitely nested keys:

    $conf.multiple.nested.keys

Override existing values:

    $conf.loaded.from.yaml = 'can override'
    $conf['loaded']['from']['yaml'] = 'can override'

Set new values:

    $conf.non_existing_value = 'can set'

Clear entire tree:

    $conf.clear

Returns nil for non-existent keys:

    $conf.non_existing -> nil
    $conf.non_existing.name -> NoMethodError: undefined method 'name' for nil:NilClass

Use `from_hash` to create non-existent nodes:

    $conf.from_hash({...})

Not dependent on Rails but easy to use with it. For example:

    $conf.load('config.yml', "#{Rails.env}.yml")

Other stuff
----------------------------------
* Works with Ruby 1.9.2
* No gem dependencies
* Fully tested with MiniTest::Spec
* Packaged as a Gem on RubyGems.org
* Less than 80 lines of code (not including tests)

Why
----------------------------------
* Because I wanted to write the simplest useful app config possible
* Others are either too simple or incomplete, lack documentation or aren't Gem installable
* Because I can :-)

Known Issues
----------------------------------
Cannot assign values to unknown nested keys because they return nil (create the tree first):

    $conf.from_hash({:non_existing => {:name => 'bla'}})

