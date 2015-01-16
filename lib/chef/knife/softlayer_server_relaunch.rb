#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerServerRelaunch < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer server relaunch <NODE NAME> [<NODE NAME>]'

      option :all,
             :short => "-a",
             :long => "--all",
             :description => "Display all available configuration options for launching an instance.",
             :default => false

      require 'chef/knife/bootstrap'
      # Make the base bootstrap options available on topo bootstrap
      self.options = (Chef::Knife::Bootstrap.options).merge(self.options)

      ##
      # Run the procedure to list softlayer VM flavors or display all available options.
      # @return [nil]
      def run
        $stdout.sync = true
        if name_args.count < 1
          ui.fatal("Server relaunch requires AT LEAST ONE node name.")
          exit 1;
        end

        ident_file = Chef::Config[:knife][:identity_file] || config[:identity_file]
        Fog.credentials[:private_key_path] = ident_file if ident_file

        Chef::Search::Query.new.search(:node, "name:#{name_args[0]}") do |object|
          @vm = connection.servers.select { |s| s.public_ip == object.ipaddress }.first
        end
        ui.fatal("Server not found on SoftLayer account.") and exit 1 unless @vm

        unless @vm.sshable?
          ui.fatal("Node with name #{name_args[0]} not sshable, relaunch canceled.")
          exit 1
        end

        # grab the contents of /etc/chef from the target node and stash a local copy
        begin
          puts ui.color("Capturing existing node configuration files.", :green)
          @vm.scp_download("/etc/chef", "/tmp/#{@vm.id}/", :recursive => true)
        rescue Exception => e
          puts ui.color(e.message, :red)
          ui.fatal('Relaunch canceled.')
          exit 1
        end

        begin
          puts ui.color("Relaunching SoftLayer server, this may take a few minutes.", :green)
          @vm.relaunch!
          @vm.wait_for { putc '.'; ready? && sshable? }
          puts ''
        rescue Exception => e
          puts ui.color(e.message, :red)
          ui.fatal('Relaunch FAILED. You may be missing a server.')
          exit 1
        end

        # push the locally stashed config items up to new machine
        begin
          puts ui.color("Installing node configuration on relaunched server.", :green)
          @vm.scp("/tmp/#{@vm.id}/chef/", "/etc/", :recursive => true)
        rescue Exception => e
          puts ui.color(e.message, :red)
          ui.fatal('Relaunch FAILED. You may be missing a chef node.')
          exit 1
        end

        begin
          puts ui.color("Installing chef-client executable on relaunched server.", :green)
          puts @vm.ssh('wget https://www.chef.io/chef/install.sh && sudo bash ./install.sh && rm install.sh').first.stdout
        rescue Exception => e
          puts ui.color(e.message, :red)
          ui.fatal('Relaunch FAILED. You may be missing a chef node.')
          exit 1
        end

        # run chef-client on the new machine with the existing config and attributes
        begin
          puts ui.color("Initial run of chef-client on relaunched server, this may take a few minutes.", :green)
          puts @vm.ssh('sudo chef-client -j /etc/chef/first-boot.json').first.stdout
        rescue Exception => e
          puts ui.color(e.message, :red)
          ui.fatal('Relaunch FAILED on chef run. Your chef node may be misconfigured.')
          exit 1
        end

      end

    end
  end
end

