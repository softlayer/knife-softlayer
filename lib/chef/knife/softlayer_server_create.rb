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
        :default => 'example.com'

      option :cores,
        :long => '--cores VALUE',
        :short => '-C VALUE',
        :description => 'The number of virtual cores SoftLayer will assign to the VM instance.',
        :default => 1

      option :os_code,
        :long => '--os-code VALUE',
        :short => '-O VALUE',
        :description => 'A valid SoftLayer operating system code.  See `knife softlayer flavor list --all` for a list of valid codes.',
        :default => 'UBUNTU_LATEST'

      option :ram,
        :long => '--ram VALUE',
        :short => '-R VALUE',
        :description => 'The number of virtual cores SoftLayer will assign to the VM instance.',
        :default => 1024

      option :block_storage,
        :long => '--block-storage VALUE',
        :short => '-B VALUE',
        :description => 'The size in GB of the block storage devices (disks) for this instance. Specify 1 - 5 entries in a comma separated list following the format "dev:size".  Example: "0:25,2:500" would be a 25GB volume on device 0 (the root partition) and a 100GB volume on on device 2. [NOTE: SoftLayer VMs always reserve device 1 for a swap device.] ',
        :default => '0:25'

      option :nic,
        :long => '--network-interface-speed VALUE',
        :short => '-n VALUE',
        :description => 'The maximum speed of the public NIC available to the instance.',
        :default => 10

      option :bill_monthly,
        :long => '--bill-monthly',
        :description => 'Flag to bill monthly instead of hourly, minimum charge of one month.',
        :boolean => true,
        :default => false

      option :single_tenant,
        :long => '--single-tenant',
        :description => 'Create a CCI VM with a dedicated physical host.',
        :boolean => true,
        :default => false

      option :san_storage,
        :long => '--san-storage',
        :description => 'Create a CCI VM with SAN based block storage [disk].',
        :boolean => true,
        :default => false

      option :datacenter,
        :long => '--datacenter VALUE',
        :description => 'Create a CCI VI in a particular datacenter.'

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
             :long => "--new-global-ip",
             :description => "Order a new SoftLayer Global IP address and assign it to the instance."

      option :hint,
             :long => "--hint HINT_NAME[=HINT_FILE]",
             :description => "Specify Ohai Hint to be set on the bootstrap target.  Use multiple --hint options to specify multiple hints.",
             :proc => Proc.new { |h|
               Chef::Config[:knife][:hints] ||= {}
               name, path = h.split("=")
               Chef::Config[:knife][:hints][name] = path ? JSON.parse(::File.read(path)) : Hash.new
             }

      ##
      # Run the procedure to create a SoftLayer VM and bootstrap it.
      # @return [nil]
      def run

        $stdout.sync = true

        config[:os_code] =~ /^WIN_/ and raise SoftlayerServerCreateError, "#{ui.color("Windows VMs not currently supported.", :red)}"

        if config[:flavor]
          @template = SoftlayerFlavorBase.load_flavor(config[:flavor])
        else
          @template = {}
          @template['startCpus'] = config[:cores]
          @template['maxMemory'] = config[:ram]
          @template['localDiskFlag'] = !config[:san_storage]
          @template['blockDevices'] = config[:block_storage].split(',').map do |i|
            dev, cap = i.split(':')
            {'device' => dev, 'diskImage' => {'capacity' => cap } }
            end
        end

        @template['complexType'] = SoftlayerBase.cci
        @template['hostname'] = config[:hostname]
        @template['domain'] = config[:domain]
        @template['dedicatedAccountHostOnlyFlag'] = config[:single_tenant]
        @template['operatingSystemReferenceCode'] = config[:os_code]
        @template['hourlyBillingFlag'] = !config[:bill_monthly]
        @template['networkComponents'] = [{ 'maxSpeed' => config[:nic]}]

        @template['datacenter'] = { 'name' => config[:datacenter] } if config[:datacenter]

        @response = connection.createObject(@template)

        puts ui.color("Launching SoftLayer CCI, this may take a few minutes.", :green)

        begin
          @cci = connection.object_mask('mask.operatingSystem.passwords.password').object_with_id(@response['id']).getObject
          sleep 1
          putc('.')
        end while @cci['operatingSystem'].nil? or @cci['operatingSystem']['passwords'].empty?

        linux_bootstrap(@cci).run

        if config[:new_global_ip] || config[:assign_global_ip]
          if config[:new_global_ip]
            begin
              order = SoftlayerBase.build_global_ipv4_order
              response = connection(:order).placeOrder(order)
              global_ip_id = response['placedOrder']['account']['globalIpv4Records'].first['id']

              if global_ip_id
                puts ui.color('Global IP Address successfully created.', :green)
              else
                raise 'Unable to find Global IP Address ID.  Address not created.'
              end
            rescue Exception => e
              puts ui.color('We have encountered a problem ordering the requested global IP.  The transaction may not have completed.', :red)
              puts ui.color(e.message, :yellow)
            end
          end

          if config[:assign_global_ip]
            global_ip_id = connection(:account).object_mask('ipAddress').getGlobalIpv4Records.map do |global_ip|
              global_ip['id'] if global_ip['ipAddress']['ipAddress'] == config[:assign_global_ip]
            end.compact.first
            if global_ip_id
              puts ui.color('Global IP Address ID found.', :green)
            end
          end

          puts ui.color('Assigning Global IP Address to Instance.', :green)
          connection(:global_ip).object_with_id(global_ip_id).route(@cci['primaryIpAddress'])

          puts ui.color('Global IP Address has been assigned.', :green)
          puts ui.color('Global IP Address will not function without networking rules on the endpoint operating system.  See http://knowledgelayer.softlayer.com/learning/global-ip-addresses for details.', :yellow)

        end

      end

      # @param [Hash] cci
      # @return [Chef::Knife::Bootstrap]
      def linux_bootstrap(cci)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [cci['primaryIpAddress']]
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:ssh_password] = cci['operatingSystem']['passwords'].first['password']
        bootstrap.config[:ssh_port] = config[:ssh_port]
        bootstrap.config[:ssh_gateway] = config[:ssh_gateway]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name) || cci['id']
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

    end
  end
end


