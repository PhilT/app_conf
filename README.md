AppConf
=======
Simplest YAML Backed Application Configuration

Installation
----------------------------------
    gem install app_conf

Usage
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
    AppConf.user.address.street -> '1 Some Road'

Syntax
----------------------------------
    AppConf.load(*filenames)
    AppConf.multiple.nested.keys
    AppConf.loaded.from.yaml = 'can override'
    AppConf.non.existing.value = 'can set'

Other stuff
----------------------------------
* Works with Ruby 1.9.2
* No gem dependencies
* Tested with MiniTest::Spec
* Not dependent on Rails but easy to use with it. For example:
    `AppConf.load('config.yml', "#{Rails.env}.yml")`

Why
----------------------------------
* Because I wanted to write the simplest app config possible
* Because I can

