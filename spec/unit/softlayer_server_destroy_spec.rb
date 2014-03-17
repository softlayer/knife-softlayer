#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/bootstrap'
require 'softlayer_api'



describe Chef::Knife::SoftlayerServerDestroy do
  before do
  end

  describe "run" do
    before(:each) do
      Chef::Config[:client_key] = nil
      @cci_attributes = {
          :id => '1000001',
          :flavor_id => 'medium',
          :fqdn => 'test.example.com',
          :public_ip_address => '33.33.33.33',
          :private_ip_address => '10.10.10.10'
      }

      @knife_softlayer_destroy = Chef::Knife::SoftlayerServerDestroy.new
      @knife_softlayer_destroy.stub(:destroy_item).and_return(true)
      @softlayer_servers = double()
      @knife_softlayer_destroy.ui.stub(:confirm)
      @knife_softlayer_destroy.stub(:msg_pair)
      @cci = double(@cci_attributes)
      @softlayer_connection =  double("connection", :createObject => {
          'accountId' => 000001,
          'createDate' => '2014-03-24T18:03:27-04:00',
          'dedicatedAccountHostOnlyFlag' => false,
          'domain' => 'example.com',
          'fullyQualifiedDomainName' => 'test',
          'hostname' =>"test",
          'id' => 0000001,
          'lastPowerStateId' => nil,
          'lastVerifiedDate' => nil,
          'maxCpu' => 4,
          'maxCpuUnits' => 'CORE',
          'maxMemory' => 4096,
          'metricPollDate' => nil,
          'modifyDate' => nil,
          'startCpus' => 4,
          'statusId' => 1001,
          'globalIdentifier' => '93f3bfb6-3f48-4e9c-82ab-25e8b5dd14ce'
      })
      @softlayer_connection.stub(:findByIpAddress).and_return({ 'id' => 100001 })
      @softlayer_connection.stub(:object_with_id).and_return(@softlayer_connection)
      @softlayer_connection.stub(:deleteObject).and_return(true)
      @knife_softlayer_destroy.ui.stub(:warn)
      @knife_softlayer_destroy.node = double("node", :name => 'foo')
      SoftLayer::Service.should_receive(:new).twice.and_return(@softlayer_connection)
    end

    it "should be talking to the softlayer api and the chef server" do
      Chef::Search::Query.stub(:new).and_return(double("query", :search => {}))
      @knife_softlayer_destroy.config[:ip_address] = '33.33.33.33'
      @softlayer_connection.should_receive(:findByIpAddress).with('33.33.33.33')
      @softlayer_connection.should_receive(:deleteObject)
      @knife_softlayer_destroy.run
    end

  end
end
