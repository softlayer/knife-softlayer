#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerVlanShow < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer vlan show ID (options)'

      def run
        unless name_args.size == 1
          puts ui.color("Specify exactly one vlan to show.", :red)
          show_usage
          exit 1
        end

        $stdout.sync = true
        vlan = connection(:network).networks.get(name_args[0])

        puts "#{ui.color("ID:", :green)} #{vlan.id}"
        puts "#{ui.color("Name:", :green)} #{vlan.name ? vlan.name : '[none]'}"
        puts "#{ui.color("Datacenter:", :green)} #{vlan.datacenter.name}"
        puts "#{ui.color("Network Space:", :green)} #{vlan.network_space}"
        puts "#{ui.color("Router:", :green)} #{vlan.router['hostname']}"
        puts "#{ui.color("Subnets:", :green)}"
        puts Formatador.display_table(vlan.subnets.map { |s| s.attributes.reject { |k,v| k.is_a?(String) } }, [:id, :cidr, :gateway_ip, :network_id, :broadcast, :type, :datacenter, :ip_version])

      end

    end
  end
end
