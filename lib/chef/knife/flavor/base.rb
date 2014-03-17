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
      # Return the flavors table or the options table.
      # @param [Boolean] show_all
      # @return [Hash]
      def table_info(show_all=false)
        if show_all
          options_table
        else
          flavors_table
        end
      end

      ##
      # Build table of all VM configuration options.
      # @return [Hash]
      def options_table
        columns = [
            ui.color("| CORES", :bold, :white, :green),
            ui.color("| RAM", :bold, :white, :green),
            ui.color("| DISK", :bold, :white, :green),
            ui.color("| OS", :bold, :white, :green),
            ui.color("| NETWORK [MBS]", :bold, :white, :green),
            ui.color("| DATACENTER", :bold, :white, :green)
        ]

        opts = connection.getCreateObjectOptions
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

      ##
      # Build the VM "flavor" table.
      # @return [Hash]
      def flavors_table
        # We don't have "flavors" actually, you can just pick from the menu.
        # Let's shim in place the standard openstack flavors so people can get started without making loads of decisions.

        columns = [
            ui.color("| FLAVOR", :bold, :green),
            ui.color("| CORES", :bold, :green),
            ui.color("| RAM", :bold, :green),
            ui.color("| DISK", :bold, :green)
        ]

        # tiny
        columns << "| tiny"
        columns << "| 1"
        columns << "| 1024"
        columns << "| 25GB [LOCAL]"

        # small
        columns << "| small"
        columns << "| 2"
        columns << "| 2048"
        columns << "| 100GB [LOCAL]"


        # medium
        columns << "| medium"
        columns << "| 4"
        columns << "| 4096"
        columns << "| 150GB [LOCAL]"


        # large
        columns << "| large"
        columns << "| 8"
        columns << "| 8192"
        columns << "| 200GB [LOCAL]"


        # xlarge
        columns << "| xlarge"
        columns << "| 16"
        columns << "| 16384"
        columns << "| 300GB [LOCAL]"
      end

      def self.load_flavor(flavor)
        self.send(flavor.to_s)
      end


      private

      ##
      # Set options for a "tiny" instance.
      # @return [Hash]
      def self.tiny
        {
            'startCpus' => 1,
            'maxMemory' => 1024,
            'localDiskFlag' => true,
            'blockDevices' => [{'device' => 0, 'diskImage' => {'capacity' => 25 } }]
        }
      end

      ##
      # Set options for a "small" instance.
      # @return [Hash]
      def self.small
        {
            'startCpus' => 2,
            'maxMemory' => 2048,
            'localDiskFlag' => true,
            'blockDevices' => [{'device' => 0, 'diskImage' => {'capacity' => 100 } }]
        }
      end

      ##
      # Set options for a "medium" instance.
      # @return [Hash]
      def self.medium
        {
            'startCpus' => 4,
            'maxMemory' => 4096,
            'localDiskFlag' => true,
            'blockDevices' => [{'device' => 0, 'diskImage' => {'capacity' => 25 } },{'device' => 2, 'diskImage' => {'capacity' => 150 } }]
        }
      end

      ##
      # Set options for a "large" instance.
      # @return [Hash]
      def self.large
        {
            'startCpus' => 8,
            'maxMemory' => 8192,
            'localDiskFlag' => true,
            'blockDevices' => [{'device' => 0, 'diskImage' => {'capacity' => 25 } },{'device' => 2, 'diskImage' => {'capacity' => 200 } }]
        }
      end

      ##
      # Set options for an "xlarge" instance.
      # @return [Hash]
      def self.xlarge
        {
            'startCpus' => 16,
            'maxMemory' => 16384,
            'localDiskFlag' => true,
            'blockDevices' => [{'device' => 0, 'diskImage' => {'capacity' => 25 } },{'device' => 2, 'diskImage' => {'capacity' => 300 } }]
        }
      end

    end
  end
end
