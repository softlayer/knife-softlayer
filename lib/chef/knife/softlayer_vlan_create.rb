#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerVlanCreate < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer vlan create'

      def run
        #unless name_args.size == 1
        #  puts ui.color("Specify exactly one vlan to show.", :red)
        #  show_usage
        #  exit 1
        #end

        $stdout.sync = true

        opts = {
          :name => ui.ask_question("Enter a vlan name:"),
          :datacenter => connection(:network).datacenters.by_name(ui.ask_question("Enter a datacenter name:")),
          :router => {'hostname' => ui.ask_question("Enter a router hostname:")},
          :network_space => ui.ask_question("Enter a network space:", :default => 'PUBLIC'),
        }

        vlan = connection(:network).networks.create(opts)

        !!vlan and puts "#{ui.color("VLAN successfully created.  Provisioning may take a few minutes to complete.", :green)}"

      end

    end
  end
end
