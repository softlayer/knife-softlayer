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

        @chef = Chef::Search::Query.new

        if config[:chef_node_name]
          @chef.search('node', "name:#{config[:chef_node_name]}") do |node|
            config[:ip_address] = node.ipaddress
            @node = node
          end
        elsif config[:ip_address]
          @chef.search('node', "ipaddress:#{config[:ip_address]}") do |node|
            @node = node
          end
        else
          raise "#{ui.color("FATAL: Please supply the node name or IP address.", :red)}"
        end
        @slid = @node.tags.select { |s| s =~ /^slid=/ }.reduce.gsub('slid=', '').to_i
        @instance = connection.servers.get(@slid)

        @node.nil? and raise "#{ui.color('Chef node not found!', :red)}"
        @instance.nil? and raise "#{ui.color('VM instance with IP: ' + config[:ip_address] +' not found!', :red)}"


        begin
          begin
            destroy_item(Chef::Node, @node.name, "node")
            puts ui.color("Chef node successfully deleted.", :green)
          rescue Exception => e
            err_msg ui.color("ERROR DELETING CHEF NODE", :red)
            err_msg ui.color(e.message, :yellow)
            err_msg ui.color(e.backtrace, :yellow)
          end

          begin
            destroy_item(Chef::ApiClient, @node.name, "client")
            puts ui.color("Chef client successfully deleted.", :green)
          rescue Exception => e
            err_msg ui.color("ERROR DELETING CHEF CLIENT", :red)
            err_msg ui.color(e.message, :yellow)
            err_msg ui.color(e.backtrace, :yellow)
          end

          begin
            @instance.destroy
            puts ui.color("SoftLayer VM successfully deleted. You are no longer being billed for this instance.", :green)
          rescue Exception => e
            err_msg ui.color("ERROR DELETING SOFTLAYER VM. IT'S POSSIBLE YOU ARE STILL BEING BILLED FOR THIS INSTANCE.  PLEASE CONTACT SUPPORT FOR FURTHER ASSISTANCE", :red)
            err_msg ui.color(e.message, :yellow)
            err_msg ui.color(e.backtrace, :yellow)
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


