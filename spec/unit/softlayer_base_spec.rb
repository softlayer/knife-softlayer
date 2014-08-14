#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/bootstrap'
require 'fog/softlayer'
Fog.mock!


describe Chef::Knife::SoftlayerBase do

  describe "connection" do
    it "should successfully create a connection using fog" do
      Chef::Config[:knife][:softlayer_username] = 'username'
      Chef::Config[:knife][:softlayer_api_key] = 'key'
      Chef::Knife::SoftlayerServerCreate.new.connection
      Chef::Knife::SoftlayerServerCreate.new.connection.should be_a(Fog::Compute::Softlayer::Mock)
    end
  end


end
