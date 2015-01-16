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


describe Chef::Knife::SoftlayerServerCreate do
  before(:each) do
    Chef::Config[:knife][:softlayer_username] = 'username'
    Chef::Config[:knife][:softlayer_api_key] = 'key'

    @server_create = Chef::Knife::SoftlayerServerCreate.new
    @server_create.stub(:tcp_test_ssh).and_return(true)

    @server_create.config[:ram] = 4096
    @server_create.config[:cores] = 4
    @server_create.config[:hostname] = 'test'
    @server_create.config[:domain] = 'ibm.com'
    @server_create.config[:datacenter] = 'hkg02'
    @server_create.config[:os_code] = 'UBUNTU_LATEST'
    @server_create.config[:block_storage] = '0:100'
  end

  describe "go-wrong cases for .run" do
    it "should raise an exception if we try to create/bootstrap a windows instance" do
      @server_create.config[:os_code] = 'WIN_2012-STD_64'
      expect { @server_create.run }.to raise_exception(Chef::Knife::SoftlayerServerCreateError)
    end


    [':ram', ':cores', ':hostname', ':domain', ':datacenter', ':os_code', ':block_storage'].each do |opt|
    class_eval <<EOS, __FILE__, __LINE__
    it "should should raise an exception if missing #{opt} option" do
      @server_create.config.delete(#{opt})
      expect { @server_create.run }.to raise_exception
    end
EOS
    end
  end

  describe "go-right cases for .run" do
    before do
      @server_create.stub(:apply_tags).and_return(Proc.new{})
      Chef::Knife::Bootstrap.any_instance.stub(:run)
      Fog::Compute::Softlayer::Server.any_instance.stub(:ready?).and_return(true)
      Fog::Compute::Softlayer::Server.any_instance.stub(:sshable?).and_return(true)
    end

    it "defaults to a distro of 'chef-full' for a linux instance" do
      @server_create.config[:distro] = @server_create.options[:distro][:default]
      bootstrap = @server_create.linux_bootstrap(double('instance', :id => 42, :ssh_ip_address => '3.3.3.3', :private_ip_address => '3.3.3.3'))
      bootstrap.config[:distro].should == 'chef-full'
    end

    it "creates an VM instance and bootstraps it" do
      @server_create.run
      @server_create.connection.virtual_guests.count.should == 1
    end

    it "sets ssh_user value by using -x option" do
      #default value of config[:ssh_user] is root
      @server_create.config[:ssh_user] = "tim-eah!"

      @server_create.run
      @server_create.config[:ssh_user].should == "tim-eah!"
      @server_create.connection.virtual_guests.count.should == 1
    end

    it "sets ssh_password value by using -P option" do
      # default value of config[:ssh_password] is nil
      @server_create.config[:ssh_password] = "passw0rd"

      @server_create.run
      @server_create.config[:ssh_password].should == "passw0rd"
      @server_create.connection.virtual_guests.count.should == 1
    end

    it "sets ssh_port value by using -p option" do
      # default value of config[:ssh_port] is 22
      @server_create.config[:ssh_port] = "86"

      @server_create.run
      @server_create.config[:ssh_port].should == "86"
      @server_create.connection.virtual_guests.count.should == 1
    end

    it "sets identity_file value by using -i option for ssh bootstrap protocol or linux image" do
      # default value of config[:identity_file] is nil
      @server_create.config[:identity_file] = "~/.ssh/mah_key_file.pem"

      @server_create.run
      @server_create.config[:identity_file].should == "~/.ssh/mah_key_file.pem"
      @server_create.connection.virtual_guests.count.should == 1
    end

  end

end
