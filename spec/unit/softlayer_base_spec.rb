#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/bootstrap'
require 'softlayer_api'


describe Chef::Knife::SoftlayerBase do

  describe "connection" do
    it "should set the user agent string that the softlayer_api gem uses" do
      Chef::Config[:knife][:softlayer_username] = 'username'
      Chef::Config[:knife][:softlayer_api_key] = 'key'
      sl = Chef::Knife::SoftlayerServerCreate.new
      sl.connection.user_agent['User-Agent'].should match /Knife Softlayer Plugin/
    end
  end


end
