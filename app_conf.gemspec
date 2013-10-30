require 'base64'

Gem::Specification.new do |s|
  s.name        = 'app_conf'
  s.version     = '0.4.2'
  s.authors     = 'Phil Thompson'
  s.email       = Base64.decode64("cGhpbEBlbGVjdHJpY3Zpc2lvbnMuY29t\n")
  s.summary     = 'Simplest YAML Backed Application Wide Configuration (AppConfig)'
  s.homepage    = 'https://github.com/PhilT/app_conf'
  s.required_rubygems_version = '>= 1.3.6'

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- spec/*`.split("\n")

  s.require_path = 'lib'
end

