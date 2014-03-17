#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/bootstrap'
require 'softlayer_api'


describe Chef::Knife::SoftlayerServerCreate do
  before(:each) do
    @knife_softlayer_create = Chef::Knife::SoftlayerServerCreate.new
    @knife_softlayer_create.stub(:tcp_test_ssh).and_return(true)

    @softlayer_connection = double("connection", :createObject => {
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

    @softlayer_servers = double("servers")
    @cci = double("cci")

    @softlayer_server_attribs = { :id => '1234567',
      :public_ip_address => '33.33.33.33',
      :private_dns_name => 'example.com',
      :private_ip_address => '10.10.10.10',
    }

    @softlayer_server_attribs.each_pair do |attrib, value|
      @cci.stub(attrib).and_return(value)
    end
  end

  describe "go-wrong cases for .run" do
    it "should raise an exception if we try to create/bootstrap a windows instance" do
      @knife_softlayer_create.config[:os_code] = 'WIN_2012-STD_64'
      expect { @knife_softlayer_create.run }.to raise_exception(Chef::Knife::SoftlayerServerCreateError)
    end
  end

  describe "go-right cases for .run" do
    before do
      @softlayer_connection.should_receive(:object_mask).with('mask.operatingSystem.passwords.password').and_return(@softlayer_servers)
      @softlayer_servers.should_receive(:object_with_id).with(1).and_return(@softlayer_servers)
      @softlayer_servers.should_receive(:getObject).and_return(@cci)
      @cci.should_receive(:[]).exactly(3).times.with('operatingSystem').and_return({'passwords' => ['foobar']})
      @cci.should_receive(:[]).with('primaryIpAddress').and_return('33.33.33.33')

      @public_ip = "33.33.33.33"
      SoftLayer::Service.should_receive(:new).twice.and_return(@softlayer_connection)


      @knife_softlayer_create.stub(:puts)
      @knife_softlayer_create.stub(:print)
      {
          :domain => 'example.com',
          :hostname => 'test',
          :flavor => 'medium',
          :chef_node_name => 'test.example.com',
      }.each do |key, value|
        @knife_softlayer_create.config[key] = value
      end

      @bootstrap = Chef::Knife::Bootstrap.new
      Chef::Knife::Bootstrap.stub(:new).and_return(@bootstrap)
      @bootstrap.should_receive(:run)
    end

    it "defaults to a distro of 'chef-full' for a linux instance" do
      @knife_softlayer_create.config[:distro] = @knife_softlayer_create.options[:distro][:default]
      @knife_softlayer_create.run
      @bootstrap.config[:distro].should == 'chef-full'
    end

    it "creates an CCI instance and bootstraps it" do
      @knife_softlayer_create.run
      @knife_softlayer_create.cci.should_not == nil
    end

    it "set ssh_user value by using -x option" do
      # default value of config[:ssh_user] is root
      @knife_softlayer_create.config[:ssh_user] = "tim-eah!"

      @knife_softlayer_create.run
      @knife_softlayer_create.config[:ssh_user].should == "tim-eah!"
      @knife_softlayer_create.cci.should_not == nil
    end

    it "set ssh_password value by using -P option" do
      # default value of config[:ssh_password] is nil
      @knife_softlayer_create.config[:ssh_password] = "passw0rd"

      @knife_softlayer_create.run
      @knife_softlayer_create.config[:ssh_password].should == "passw0rd"
      @knife_softlayer_create.cci.should_not == nil
    end

    it "set ssh_port value by using -p option" do
      # default value of config[:ssh_port] is 22
      @knife_softlayer_create.config[:ssh_port] = "86"

      @knife_softlayer_create.run
      @knife_softlayer_create.config[:ssh_port].should == "86"
      @knife_softlayer_create.cci.should_not == nil
    end

    it "set identity_file value by using -i option for ssh bootstrap protocol or linux image" do
      # default value of config[:identity_file] is nil
      @knife_softlayer_create.config[:identity_file] = "~/.ssh/mah_key_file.pem"

      @knife_softlayer_create.run
      @knife_softlayer_create.config[:identity_file].should == "~/.ssh/mah_key_file.pem"
      @knife_softlayer_create.cci.should_not == nil
    end

  end

end
