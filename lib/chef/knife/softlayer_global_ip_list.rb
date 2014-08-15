#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerGlobalIpList < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer global ip list (options)'

      def run
        $stdout.sync = true

        if connection(:network).get_global_ip_records.body.empty?
          puts ui.color("No global ip addresses found.", :green)
        else
          puts ui.color("This operation can take several minutes.  ", :yellow)
          table_data = connection(:network).ips.map do |ip|
            {:address => ip.address, :destination => ip.destination_ip.respond_to?(:address) ? ip.destination_ip.address : 'NOT ROUTED'} if ip.global?
          end.compact
          puts Formatador.display_table(table_data, [:address, :destination])
        end
      end

    end
  end
end
