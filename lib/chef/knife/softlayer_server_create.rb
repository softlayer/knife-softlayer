#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife/softlayer_base'

class Chef
  class Knife
    class SoftlayerServerCreateError < StandardError; end
    class SoftlayerServerCreate < Knife

      attr_reader :cci

      include Knife::SoftlayerBase

      banner 'knife softlayer server create (options)'

      option :flavor,
        :long => '--flavor FLAVOR',
        :short => '-f FLAVOR',
        :description => 'Pre-configured packages of computing resources.  See `knife softlayer flavor list` for details.'

      option :hostname,
        :long => '--hostname VALUE',
        :short => '-H VALUE',
        :description => 'The hostname SoftLayer will assign to the VM instance.'

      option :domain,
        :long => '--domain VALUE',
        :short => '-D VALUE',
        :description => 'The FQDN SoftLayer will assign to the VM instance.',
        :default => Chef::Config[:knife][:softlayer_default_domain]

      option :cores,
        :long => '--cores VALUE',
        :short => '-C VALUE',
        :description => 'The number of virtual cores SoftLayer will assign to the VM instance.'

      option :os_code,
        :long => '--os-code VALUE',
        :short => '-O VALUE',
        :description => 'A valid SoftLayer operating system code.  See `knife softlayer flavor list --all` for a list of valid codes.'

      option :ram,
        :long => '--ram VALUE',
        :short => '-R VALUE',
        :description => 'The number of virtual cores SoftLayer will assign to the VM instance.'


      option :block_storage,
        :long => '--block-storage VALUE',
        :short => '-B VALUE',
        :description => 'The size in GB of the block storage devices (disks) for this instance. Specify 1 - 5 entries in a comma separated list following the format "dev:size".  Example: "0:25,2:500" would be a 25GB volume on device 0 (the root partition) and a 100GB volume on on device 2. [NOTE: SoftLayer VMs always reserve device 1 for a swap device.] ',
        :proc => Proc.new { |devs| devs.split(',').map{ |dev| device, capacity = dev.split(':'); {"device"=>device, "diskImage"=>{"capacity"=>capacity}}  }  }

      option :nic,
        :long => '--network-interface-speed VALUE',
        :short => '-n VALUE',
        :description => 'The maximum speed of the public NIC available to the instance.',
        :default => nil

      option :bill_monthly,
        :long => '--bill-monthly',
        :description => 'Flag to bill monthly instead of hourly, minimum charge of one month.',
        :boolean => true,
        :default => false

      option :vlan,
         :long => '--vlan VLAN-ID',
         :description => 'Internal SoftLayer ID of the public VLAN into which the compute instance should be placed.'

      option :private_vlan,
         :long => '--private-vlan VLAN-ID',
         :description => 'Internal SoftLayer ID of the private VLAN into which the compute instance should be placed.'

      option :image_id,
        :long => '--image-id IMAGE-ID',
        :description => 'Internal SoftLayer uuid specifying the image template from which the compute instance should be booted.'

      option :private_network_only,
        :long => '--private-network-only',
        :description => 'Flag to be passed when the compute instance should have no public facing network interface.',
        :boolean => true

      option :use_private_network,
        :long => '--use-private-network',
        :description => 'Flag to be passwed when bootstrap is preferred over the private network.',
        :boolean => true

      option :from_file,
             :long => '--from-file PATH',
             :description => 'Path to JSON file containing arguments for provisoning and bootstrap.'

      #option :single_tenant,
      #  :long => '--single-tenant',
      #  :description => 'Create a VM with a dedicated physical host.',
      #  :boolean => true,
      #  :default => false

      option :local_storage,
        :long => '--local-storage',
        :description => 'Force local block storage instead of SAN storage.',
        :boolean => true,
        :default => false

      option :datacenter,
        :long => '--datacenter VALUE',
        :description => 'Create a VM in a particular datacenter.',
        :default => Chef::Config[:knife][:softlayer_default_datacenter]

      option :tags,
             :short => "-T T=V[,T=V,...]",
             :long => "--tags Tag=Value[,Tag=Value...]",
             :description => "The tags for this server",
             :proc => Proc.new { |tags| tags.split(',') }

      option :chef_node_name,
             :short => "-N NAME",
             :long => "--node-name NAME",
             :description => "The Chef node name for your new node",
             :proc => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }

      option :ssh_user,
             :short => "-x USERNAME",
             :long => "--ssh-user USERNAME",
             :description => "The ssh username",
             :default => "root"

      option :ssh_password,
             :short => "-P PASSWORD",
             :long => "--ssh-password PASSWORD",
             :description => "The ssh password"

      option :ssh_keys,
              :short => "-S KEY",
              :long => "--ssh-keys KEY",
              :description => "The ssh keys for the SoftLayer Virtual Guest environment. Accepts a space separated list of integers.",
              :proc => Proc.new { |ssh_keys| ssh_keys.split(' ')  }

      option :ssh_port,
             :short => "-p PORT",
             :long => "--ssh-port PORT",
             :description => "The ssh port",
             :default => "22",
             :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

      option :ssh_gateway,
             :short => "-w GATEWAY",
             :long => "--ssh-gateway GATEWAY",
             :description => "The ssh gateway server",
             :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

      option :identity_file,
             :short => "-i IDENTITY_FILE",
             :long => "--identity-file IDENTITY_FILE",
             :description => "The SSH identity file used for authentication"

      option :prerelease,
             :long => "--prerelease",
             :description => "Install the pre-release chef gems"

      option :bootstrap_version,
             :long => "--bootstrap-version VERSION",
             :description => "The version of Chef to install",
             :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }

      option :bootstrap_proxy,
             :long => "--bootstrap-proxy PROXY_URL",
             :description => "The proxy server for the node being bootstrapped",
             :proc => Proc.new { |p| Chef::Config[:knife][:bootstrap_proxy] = p }

      option :distro,
             :short => "-d DISTRO",
             :long => "--distro DISTRO",
             :description => "Bootstrap a distro using a template; default is 'chef-full'",
             :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
             :default => "chef-full"

      option :template_file,
             :long => "--template-file TEMPLATE",
             :description => "Full path to location of template to use",
             :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
             :default => false

      option :run_list,
             :short => "-r RUN_LIST",
             :long => "--run-list RUN_LIST",
             :description => "Comma separated list of roles/recipes to apply",
             :proc => lambda { |o| o.split(/[\s,]+/) }

      option :secret,
             :short => "-s SECRET",
             :long => "--secret ",
             :description => "The secret key to use to encrypt data bag item values",
             :proc => lambda { |s| Chef::Config[:knife][:secret] = s }

      option :secret_file,
             :long => "--secret-file SECRET_FILE",
             :description => "A file containing the secret key to use to encrypt data bag item values",
             :proc => lambda { |sf| Chef::Config[:knife][:secret_file] = sf }

      option :json_attributes,
             :short => "-j JSON",
             :long => "--json-attributes JSON",
             :description => "A JSON string to be added to the first run of chef-client",
             :proc => lambda { |o| JSON.parse(o) }

      option :host_key_verify,
             :long => "--[no-]host-key-verify",
             :description => "Verify host key, enabled by default.",
             :boolean => true,
             :default => true

      option :bootstrap_protocol,
             :long => "--bootstrap-protocol protocol",
             :description => "protocol to bootstrap windows servers. options: winrm/ssh",
             :proc => Proc.new { |key| Chef::Config[:knife][:bootstrap_protocol] = key },
             :default => nil

      option :fqdn,
             :long => "--fqdn FQDN",
             :description => "Pre-defined FQDN",
             :proc => Proc.new { |key| Chef::Config[:knife][:fqdn] = key },
             :default => nil

      option :assign_global_ip,
             :long => "--assign-global-ip IpAdress",
             :description => "Assign an existing SoftLayer Global IP address.",
             :default => nil

      option :new_global_ip,
             :long => "--new-global-ip VERSION",
             :description => "Order a new SoftLayer Global IP address and assign it to the instance."

      option :hint,
             :long => "--hint HINT_NAME[=HINT_FILE]",
             :description => "Specify Ohai Hint to be set on the bootstrap target.  Use multiple --hint options to specify multiple hints.",
             :proc => Proc.new { |h|
               Chef::Config[:knife][:hints] ||= {}
               name, path = h.split("=")
               Chef::Config[:knife][:hints][name] = path ? JSON.parse(::File.read(path)) : Hash.new
             }

      option :user_data,
             :short => "-u USERDATA",
             :long => "--user-data USERDATA",
             :description => "Optional user data to pass on to SoftLayer compute instance"

      require 'chef/knife/bootstrap'
      # Make the base bootstrap options available on topo bootstrap
      self.options = (Chef::Knife::Bootstrap.options).merge(self.options)

      ##
      # Run the procedure to create a SoftLayer VM and bootstrap it.
      # @return [nil]
      def run
        $stdout.sync = true
        config.merge!(slurp_from_file(config[:from_file])) if config[:from_file]

        # TODO: Windows support.
        raise SoftlayerServerCreateError, "#{ui.color("Windows VMs not currently supported.", :red)}" if config[:os_code] =~ /^WIN_/
        raise SoftlayerServerCreateError, "#{ui.color("identity file (-i) option is incompatible with password (-P) option required.", :red)}" if !!config[:identity_file] and !!config[:ssh_password]
        raise SoftlayerServerCreateError, "#{ui.color("--new-global-ip value must be 'v4' or 'v6'.", :red)}" if config[:new_global_ip] and !config[:new_global_ip].to_s.match(/^v[4,6]$/i)

        # TODO: create a pre-launch method for clean up tasks.
        # TODO: create a pre-launch method for clean up tasks.
        config[:vlan] = config[:vlan].to_i if config[:vlan]
        config[:private_vlan] = config[:private_vlan].to_i if config[:private_vlan]
        Fog.credentials[:private_key_path] = config[:identity_file] if config[:identity_file]
        # TODO: create a pre-launch method for clean up tasks.
        # TODO: create a pre-launch method for clean up tasks.

        opts = {
            :flavor => :flavor_id,
            :hostname => :name,
            :domain => nil,
            :cores => :cpu,
            :os_code => nil,
            :ram => nil,
            :block_storage => :disk,
            :local_storage => :ephemeral_storage,
            :datacenter => nil,
            :ssh_keys => :key_pairs,
            :vlan => nil,
            :private_vlan => nil,
            :image_id => nil,
            :private_network_only => nil,
            #:tags => nil,
            :user_data => nil
        }


        opts.keys.each do |opt|
          if opts[opt].nil?
            opts[opt] = config[opt]
          else
            opts[opts.delete(opt)] = config[opt]  # clever shit like this is why I like programming :-]
          end
        end

        # FIXME: make the above deal with nested opts and get rid of this one-off
        opts[:network_components] = [ {:speed => config[:nic]} ] if !!config[:nic]

        opts.delete_if { |k,v| v.nil? }
        puts ui.color("Launching SoftLayer VM, this may take a few minutes.", :green)
        instance = connection.servers.create(opts)
        if config[:private_network_only] || config[:use_private_network]
          instance.ssh_ip_address = Proc.new {|server| server.private_ip_address }
        end
        progress Proc.new { instance.wait_for { ready? and sshable? } }
        putc("\n")

        if config[:tags]
          puts ui.color("Applying tags to SoftLayer instance.", :green)
          progress Proc.new { instance.add_tags(config[:tags]) }
          putc("\n")
        end


        if config[:new_global_ip] || config[:assign_global_ip]
          if config[:new_global_ip] # <— the value of this will be v4 or v6
            begin
              puts ui.color('Provisioning new Global IP' + config[:new_global_ip].downcase + ', this may take a few minutes.', :green)
              create_global_ip =  Proc.new do
                existing_records = connection(:network).get_global_ip_records.body
                connection(:network).send('create_new_global_ip' + config[:new_global_ip].downcase) or raise SoftlayerServerCreateError, "Unable to create new Global IP Address.";
                sleep 20 # if we look for the new record too quickly it won't be there yet...
                new_record_global_id = (connection(:network).get_global_ip_records.body - existing_records).reduce['id']
                connection(:network).ips.select { |ip| ip.global_id == new_record_global_id }.reduce
              end
              global_ip = progress(create_global_ip) or raise SoftlayerServerCreateError, "Error encountered creating Global IP Address."
              puts ui.color('Global IP Address successfully created.', :green)
            rescue SoftlayerServerCreateError => e
              puts ui.color('We have encountered a problem ordering the requested global IP.  The transaction may not have completed.', :red)
              puts ui.color(e.message, :yellow)
            end
          end

          if config[:assign_global_ip]
            case config[:assign_global_ip].to_s
              #ipv4
              when /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/
                global_ip = connection(:network).ips.by_address(config[:assign_global_ip])
              #ipv6
              when /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/
                global_ip = connection(:network).ips.by_address(config[:assign_global_ip])
              else
                raise SoftlayerServerCreateError, "--assign-global-ip value must be valid IPv4 or IPv6 address"
            end
            global_ip or raise SoftlayerServerCreateError, "Global IP address not found.  Please check the address or id supplied and try again."
            global_ip.reload
          end

          route_global_ip = Proc.new do
            puts ui.color('Routing Global IP Address to Instance.', :green)
            global_ip.route(connection(:network).ips.by_address(instance.public_ip_address)) or raise SoftlayerServerCreateError, "Global IP address failed to route."
            puts ui.color('Global IP Address has been assigned.', :green)
            puts ui.color('Global IP Address will not function without networking rules on the endpoint operating system.  See http://knowledgelayer.softlayer.com/learning/global-ip-addresses for details.', :yellow)
          end
          progress(route_global_ip)

        end

        puts ui.color('Bootstrapping Chef node, this may take a few minutes.', :green)
        linux_bootstrap(instance).run

        puts ui.color("Applying tags to Chef node.", :green)
        progress apply_tags(instance)

      end

      # @param [Hash] instance
      # @return [Chef::Knife::Bootstrap]
      def linux_bootstrap(instance)
        bootstrap = Chef::Knife::Bootstrap.new
        instance.ssh_ip_address = instance.private_ip_address if config[:private_network_only]
        bootstrap.name_args = [instance.ssh_ip_address]
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:ssh_password] = config[:ssh_password] if config[:ssh_password]
        bootstrap.config[:identity_file] = config[:identity_file] if config[:identity_file]
        bootstrap.config[:ssh_port] = config[:ssh_port]
        bootstrap.config[:ssh_gateway] = config[:ssh_gateway]
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name) || instance.id
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:host_key_verify] = config[:host_key_verify]
        shared_bootstrap(bootstrap)
      end

      # @param [Chef::Knife::Bootstrap] bootstrap
      # @return [Chef::Knife::Bootstrap]
      def shared_bootstrap(bootstrap)
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = locate_config_value(:environment)
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:first_boot_attributes] = locate_config_value(:json_attributes) || {}
        bootstrap.config[:encrypted_data_bag_secret] = locate_config_value(:encrypted_data_bag_secret)
        bootstrap.config[:encrypted_data_bag_secret_file] = locate_config_value(:encrypted_data_bag_secret_file)
        bootstrap.config[:secret] = locate_config_value(:secret)
        bootstrap.config[:secret_file] = locate_config_value(:secret_file)
        bootstrap.config[:tags] = locate_config_value(:tags)
        bootstrap.config[:fqdn] = locate_config_value(:fqdn)
        Chef::Config[:knife][:hints] ||= {}
        Chef::Config[:knife][:hints]['softlayer'] ||= {}
        bootstrap
      end

      def windows_bootstrap(server, fqdn)
        # TODO: Windows support....
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

      def slurp_from_file(path)
        args = JSON.parse(IO.read(path))
        args.keys.each { |key| args[key.gsub('-', '_').to_sym] = args.delete(key) }
        # TODO: Something less ugly than the empty rescue block below.  The :proc Procs/Lambdas aren't idempotent...
        args.keys.each { |key| begin; args[key] = options[key][:proc] ? options[key][:proc].call(args[key]) : args[key]; rescue; end }
        args
      end

      def apply_tags(instance)
        Proc.new do
          chef = Chef::Search::Query.new
          chef.search('node', "name:#{locate_config_value(:chef_node_name) || instance.id}") do |n|
            config[:tags] = [] if config[:tags].nil? # we're going to tag every Chef node with the SL id no matter what
            config[:tags] << "slid=#{instance.id}"
            config[:tags].each do |tag|
              n.tag(tag)
            end
            n.save
          end
        end
      end

    end
  end
end


