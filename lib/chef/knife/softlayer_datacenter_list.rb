#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerDatacenterList < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer datacenter list (options)'

      def run
        $stdout.sync = true
        table_data = connection(:network).datacenters.map do |dc|
          {:name => dc.name, :long_name => dc.long_name }
        end
        puts Formatador.display_table(table_data, [:name, :long_name])
      end

    end
  end
end
