#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerKeyPairCreate < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer key pair create'

      def run
        $stdout.sync = true
        opts = {
            :label => ui.ask_question("Enter the label for this key pair: "),
            :key => ui.ask("Enter path to the public key: ", lambda{ |answer| IO.read(answer) })
        }

        key_pair = connection(:compute).key_pairs.create(opts)

        if !!key_pair
          puts "#{ui.color("Key pair successfully created.  Provisioning may take a few minutes to complete.", :green)}"
          puts "#{ui.color("Key pair ID is: ", :green)} #{key_pair.id}"
        else
          puts "#{ui.color("Encountered a problem verifying key pair creation.  Please try again.", :yellow)}"
        end
      end

    end
  end
end
