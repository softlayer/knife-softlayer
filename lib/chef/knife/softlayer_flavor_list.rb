#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'
require 'chef/knife/flavor/base'

class Chef
  class Knife
    class SoftlayerFlavorList < Knife

      include Knife::SoftlayerBase
      include Knife::SoftlayerFlavorBase

      banner 'knife softlayer flavor list (options)'

      option :all,
             :short => "-a",
             :long => "--all",
             :description => "Display all available configuration options for launching an instance.",
             :default => false

      ##
      # Run the procedure to list softlayer VM flavors or display all available options.
      # @return [nil]
      def run
        $stdout.sync = true
        if config[:all]

          if OS.windows?
            puts ui.list(options_table, :uneven_columns_across, 6)
          else
            IO.popen('less', 'w') do |pipe|
              pipe.puts ui.list(options_table, :uneven_columns_across, 6)
            end
          end

          msg = "These options can be used in place of 'flavors'; See `knife softlayer server create --help` for details.\n"
        else
          puts connection.flavors.table([:id, :cpu, :ram, :disk,])
          msg = "'flavors' provided here for convenience; SoftLayer allows you to choose a configuration a la carte.\nFor a full list of available instance options use --all with the `knife softlayer flavor list` subcommand."
        end
        puts ui.color("\nNOTICE: ", :yellow)
        puts ui.color(msg)
      end

    end
  end
end

