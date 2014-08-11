#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerDatacenterShow < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer datacenter show DATACENTER'

      option :dc,
             :short => "-a",
             :long => "--all",
             :description => "Display all available configuration options for launching an instance.",
             :default => false


      def run
        unless name_args.size == 1
          puts ui.color("Specify exactly one datacenter to show.", :red)
          show_usage
          exit 1
        end

        $stdout.sync = true
        dc = connection(:network).datacenters.by_name(name_args[0])

        puts "#{ui.color("Long Name:", :green)} #{dc.long_name}"
        puts "#{ui.color("Name:", :green)} #{dc.name}"

        puts "#{ui.color("Routers:", :green)}"
        puts Formatador.display_table(dc.routers)

      end

    end
  end
end
