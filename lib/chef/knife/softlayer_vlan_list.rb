#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerVlanList < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer vlan list (options)'

      def run
        $stdout.sync = true
        table_data = connection(:network).networks.map do |net|
          {:id => net.id, :name => net.name ? net.name : '[none]', :datacenter => net.datacenter.long_name, :network_space => net.network_space, :router => net.router['hostname'] }
        end
        puts Formatador.display_table(table_data, [:id, :name, :datacenter, :network_space, :router])
      end

    end
  end
end
