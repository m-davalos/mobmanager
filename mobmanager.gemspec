# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mobmanager/version'

Gem::Specification.new do |spec|
  spec.name          = "mobmanager"
  spec.version       = Mobmanager::VERSION
  spec.authors       = ['Milton Davalos']
  spec.email         = ['mdavalos@mobiquityinc.com']
  spec.summary       = %q{Provides methods to manage Appium server}
  spec.description   = %q{Provides methods to start/end Appium server and management of apps in Android and iOS}
  spec.homepage      = 'https://github.com/m-davalos/mobmanager'
  spec.license       = 'Mobiquity, Inc.'
  spec.files         = `git ls-files`.split("\n")
  spec.require_paths = ["lib"]
  spec.add_dependency 'require_all'
end
