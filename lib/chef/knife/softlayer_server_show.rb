require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerServerShow < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer server show ID (options)'

      ##
      # Run the procedure to list all of the Softlayer VM's
      # @return [nil]
      def run
        unless name_args.size == 1
          puts ui.color("Specify a node ID to show.", :red)
          show_usage
          exit 1
        end
        $stdout.sync = false
        server = connection.servers.get(name_args[0])

        puts "#{ui.color("ID:", :green)} #{server.id}"
        puts "#{ui.color("Name:", :green)} #{server.fqdn}"
        puts "#{ui.color("CPU:", :green)} #{server.cpu}"
        puts "#{ui.color("RAM:", :green)} #{server.ram}"
        puts "#{ui.color("Datacenter:", :green)} #{server.datacenter}"
        puts "#{ui.color("Public IP:", :green)} #{server.public_ip_address}"
        puts "#{ui.color("Public Speed:", :green)} #{server.network_components[0].speed}"
        puts "#{ui.color("Private IP:", :green)} #{server.private_ip_address}"
        puts "#{ui.color("Private Speed:", :green)} #{server.network_components[1].speed}"
        puts "#{ui.color("Status:", :green)} #{server.state}"
      end
    end
  end
end
