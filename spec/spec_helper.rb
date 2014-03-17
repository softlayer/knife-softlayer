#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef'
require 'chef/knife/winrm_base'
require 'chef/knife/softlayer_server_create'
require 'chef/knife/softlayer_server_destroy'

# Clear config between each example
# to avoid dependencies between examples
RSpec.configure do |c|
  c.before(:each) do
    Chef::Config.reset
    Chef::Config[:knife] ={}
  end
end
