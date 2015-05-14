#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'
require 'chef/search/query'
require 'chef/api_client'

class Chef
  class Knife
    class SoftlayerServerDestroy < Knife

      attr_accessor :node
      attr_accessor :cci

      include Knife::SoftlayerBase

      banner 'knife softlayer server destroy (options)'

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node to be destroyed."

      option :ip_address,
        :long => "--ip-address ADDRESS",
        :short => "-I",
        :description => "Find the VM and node to destroy by its public IP address."

      ##
      # Run the procedure to destroy a SoftLayer VM and clean up its Chef node and client.
      # @return [nil]
      def run

        $stdout.sync = true

        puts ui.color("Decommissioning SoftLayer VM, this may take a few minutes.", :green)
        connection.servers.each do |server|
          if config[:ip_address]
            if server.public_ip_address == config[:ip_address]
              @instance = server
              break
            end
          elsif config[:chef_node_name]
            if server.name == config[:chef_node_name]
              config[:ip_address] = server.public_ip_address
              @instance = server
              break
            end
          elsif  arg = name_args[0]
            if arg =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/ # ipv4
              if server.public_ip_address == arg
                @instance = server
                break
              end
            elsif arg =~ /^(?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}$/ # ipv6
              if server.public_ip_address == arg
                @instance = server
                break
              end
            else
              if server.name == arg
                config[:ip_address] = server.public_ip_address
                @instance = server
                break
              end
            end
          end              
        end
        @instance.nil? and raise "#{ui.color('VM instance with IP: ' + (config[:ip_address].to_s) +' not found!', :red)}"
        @chef = Chef::Search::Query.new
        @chef.search('node', "name:#{@instance.name}") do |node|
          begin
            @node = node               
          rescue
          end
        end

        begin
          if @node
            begin
              destroy_item(Chef::Node, @node.name, "node")
              puts ui.color("Chef node successfully deleted.", :green)
            rescue Exception => e
              err_msg ui.color("ERROR DELETING CHEF NODE", :red)
              err_msg ui.color(e.message, :yellow)
              err_msg ui.color(e.backtrace.join("\n"), :yellow)
            end

            begin
              destroy_item(Chef::ApiClient, @node.name, "client")
              puts ui.color("Chef client successfully deleted.", :green)
            rescue Exception => e
              err_msg ui.color("ERROR DELETING CHEF CLIENT", :red)
              err_msg ui.color(e.message, :yellow)
              err_msg ui.color(e.backtrace.join("\n"), :yellow)
            end
          else
            "#{ui.color('Chef node: ' + config[:chef_node_name] +' not found! will destroy instance.', :red)}"
          end

          begin
            @instance.destroy
            puts ui.color("SoftLayer VM successfully deleted. You are no longer being billed for this instance.", :green)
          rescue Exception => e
            err_msg ui.color("ERROR DELETING SOFTLAYER VM. IT'S POSSIBLE YOU ARE STILL BEING BILLED FOR THIS INSTANCE.  PLEASE CONTACT SUPPORT FOR FURTHER ASSISTANCE", :red)
            err_msg ui.color(e.message, :yellow)
            err_msg ui.color(e.backtrace.join("\n"), :yellow)
          end
        ensure
          unless err_msg.empty?
            err_msg.each do |msg|
              puts msg
            end
          end
        end

      end

      # @param [Chef::*] klass
      # @param [String] name
      # @param [String] type_name
      # @return [nil]
      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end

      def err_msg(msg=nil)
        @msgs ||= []
        @msgs.push(msg).compact
      end

    end
  end
end


