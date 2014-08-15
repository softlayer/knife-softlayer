#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerKeyPairList < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer key pair list'

      def run
        $stdout.sync = true
        table_data = connection(:compute).key_pairs.map do |kp|
          {:id => kp.id, :label => kp.label,  :create_date => kp.create_date, :modify_date => kp.modify_date }
        end
        puts Formatador.display_table(table_data, [:id, :label, :create_date, :modify_date])
      end

    end
  end
end
