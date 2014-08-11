#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife'

class Chef
  class Knife
    module SoftlayerFlavorBase

      ##
      # Build table of all VM configuration options.
      # @return [Hash]
      def options_table
        columns = [
            "| CORES",
            "| RAM",
            "| DISK",
            "| OS",
            "| NETWORK [MBS]",
            "| DATACENTER",
        ]

        6.times { columns << '| ========== ' }

        opts = connection.request(:virtual_guest, :get_create_object_options).body
        cpu = opts['processors']
        ram = opts['memory']
        disk = opts['blockDevices'].sort_by{|d| d['itemPrice']['item']['description'] unless d['itemPrice'].nil? }
        os = opts['operatingSystems']
        net = opts['networkComponents']
        datacenter = opts['datacenters']

        i = 0
        until i >= opts.keys.map{|key| opts[key].count }.sort.last do
          columns << (cpu[i].nil? ? '|  ' : '|  ' + cpu[i]['itemPrice']['item']['description'])
          columns << (ram[i].nil? ? '|  ' : '|  ' + ram[i]['template']['maxMemory'].to_s + " [#{ram[i]['itemPrice']['item']['description']}]")
          columns << (disk[i].nil? ? '|  ' : '|  ' + disk[i]['itemPrice']['item']['description'])
          columns << (os[i].nil? ? '|  ' : '|  ' + os[i]['template']['operatingSystemReferenceCode'])
          columns << (net[i].nil? ? '|  ' : '|  ' + net[i]['template']['networkComponents'].first['maxSpeed'].to_s)
          columns << (datacenter[i].nil? ? '|  ' : '|  ' + datacenter[i]['template']['datacenter']['name'])
          i+=1
        end
        columns
      end

    end
  end
end
