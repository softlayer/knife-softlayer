require 'chef/knife/softlayer_base'
require 'chef/search/query'
require 'chef/api_client'

class Chef
  class Knife
    class SoftlayerServerList < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer server list (options)'

      ##
      # Run the procedure to list all of the Softlayer VM's
      # @return [nil]
      def run

        $stdout.sync = true
        fmt = "%-20s %-8s %-15s %-15s %-10s"
        puts ui.color(sprintf(fmt, "Name", "Location", "Public IP", "Private IP", "Status"), :green)
        connection.servers.each do |server|
          puts sprintf fmt, server.name, server.datacenter, server.public_ip_address, server.private_ip_address, server.created_at ? 'Running' : 'Starting'
        end
      end
    end
  end
end
