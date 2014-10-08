#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-softlayer/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-softlayer"
  spec.version       = Knife::Softlayer::VERSION
  spec.authors       = ["Matt Eldridge"]
  spec.email         = ["matt.eldridge@us.ibm.com"]
  spec.summary       = %q{SoftLayer VM support for Chef's knife utility.}
  spec.description   = %q{A knife plugin for launching and bootstrapping instances in the IBM SoftLayer cloud.}
  spec.homepage      = "https://github.com/SoftLayer/knife-softlayer"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fog-softlayer", "~> 0.3", ">= 0.3.20"
  spec.add_dependency "knife-windows", "> 0.5.12"
  spec.add_dependency "net-ssh", "> 2.8.0"
#############################################
#############################################
#############################################
spec.add_dependency "pry"
spec.add_dependency "pry-debugger"
#############################################
#############################################
#############################################

  spec.add_development_dependency "mixlib-config", "~>2.0"
  spec.add_development_dependency "chef", ">=0.10.10"
  spec.add_development_dependency "rspec", "~>2.14"
  spec.add_development_dependency "rake", "~>10.1"
  spec.add_development_dependency "sdoc", "~>0.3"
  spec.add_development_dependency "bundler", "~>1.5"
  spec.add_development_dependency "osrcry"
end
