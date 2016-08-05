#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerImageList < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer image list'

      def run
        $stdout.sync = true
        table_data = connection(:compute).images.map { |i| {:id => i.id, :name => i.name, :access => i.public? ? 'PUBLIC' : 'PRIVATE', :account => i.account_id } }
        puts Formatador.display_table(table_data, [:id, :access, :name, :account])
      end

    end
  end
end
