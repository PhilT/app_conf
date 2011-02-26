AppConf
=======
Simplest YAML backed Application configuration

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
* Tested with RSpec
* Works with Ruby 1.9.2
* Not dependent on Rails but easy to use with it. For example:
    AppConf.load('config.yml', "#{Rails.env}.yml")

Why
----------------------------------
* Because I wanted to write the simplest app config possible
* Because I can

