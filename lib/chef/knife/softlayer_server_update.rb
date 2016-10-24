require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerServerUpdate < Knife

      include Knife::SoftlayerBase

      banner 'knife softlayer server update ID (options)'

      option :ram,
             :long => "--ram SIZE",
             :description => "update ram size. In GBs"

      option :cpu,
             :long => "--cpu COUNT",
             :description => "update cpu count"

      option :time,
             :long => "--time Time",
             :description => "set time when to make a change",
             :default => Time.now

      ##
      # Run the procedure to list all of the Softlayer VM's
      # @return [nil]
      def run
        unless name_args.size == 1
          puts ui.color("Specify a node ID to update.", :red)
          show_usage
          exit 1
        end

        new_attributes = Mash.new

        new_attributes[:guest_core] = config[:cpu] unless config[:cpu].nil?
        new_attributes[:ram] = config[:ram] unless config[:ram].nil?
        new_attributes[:time] = config[:time]

        $stdout.sync = true
        server = connection.servers.get(name_args[0])
        server.update(new_attributes)
        sleep 9

        progress Proc.new { server.wait_for { ready? } }

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

      def progress(proc)
        t = Thread.new { Thread.current[:output] = proc.call }
        i = 0
        while t.alive?
          sleep 0.5
          putc('.')
          i += 1
          putc("\n") if i == 76
          i = 0 if i == 76
        end
        putc("\n")
        t.join
        t[:output]
      end
    end
  end
end
