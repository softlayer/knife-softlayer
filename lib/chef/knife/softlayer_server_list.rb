require 'chef/knife/softlayer_base'
require 'chef/search/query'
require 'chef/api_client'

class Chef
  class Knife
    class SoftlayerServerList < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer server list (options)'

      option :datacenter,
             :long => '--datacenter VALUE',
             :description => 'Filter by a particular datacenter.',
             :default => Chef::Config[:knife][:softlayer_default_datacenter]
      ##
      # Run the procedure to list all of the Softlayer VM's
      # @return [nil]
      def run

        $stdout.sync = false
        fmt = "%-8s %-30s %-8s %-15s %-15s %-10s"
        puts ui.color(sprintf(fmt, "ID", "FQDN", "Location", "Public IP", "Private IP", "Status"), :green)
        connection.servers.each do |server|
          puts sprintf fmt, server.id, server.fqdn , server.datacenter, server.public_ip_address, server.private_ip_address, server.state if config[:datacenter].nil? || config[:datacenter] == server.datacenter
        end
      end
    end
  end
end
