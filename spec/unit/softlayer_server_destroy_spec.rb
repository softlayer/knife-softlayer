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


describe Chef::Knife::SoftlayerServerDestroy do
  before(:each) do
    Chef::Config[:knife][:softlayer_username] = 'username'
    Chef::Config[:knife][:softlayer_api_key] = 'key'


    @attributes = {
        :id => '1000001',
        :name => '1000001',
        :flavor_id => 'medium',
        :fqdn => 'test.example.com',
        :public_ip_address => '33.33.33.33',
        :private_ip_address => '10.10.10.10',
        :tags => ['slid=1000001']
    }

    @knife_softlayer_destroy = Chef::Knife::SoftlayerServerDestroy.new
    @knife_softlayer_destroy.connection.virtual_guests = @vm_attributes
    @knife_softlayer_destroy.node = double("node", @attributes)
    @knife_softlayer_destroy.stub(:destroy_item)
    instance = double(@attributes)
    @knife_softlayer_destroy.stub_chain(:connection, :servers, :get).and_return(instance)


  end

  it "should be talking to the softlayer api and the chef server" do
    Chef::Search::Query.stub(:new).and_return(double("query", :search => {}))
    @knife_softlayer_destroy.config[:ip_address] = '33.33.33.33'
    @knife_softlayer_destroy.connection.servers.get.should_receive(:destroy)
    @knife_softlayer_destroy.run
  end

end
