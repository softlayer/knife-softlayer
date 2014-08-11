#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife'
require 'knife-softlayer/version'
require 'pry'

class Chef
  class Knife
    module SoftlayerBase

      USER_AGENT = "Chef Knife Softlayer Plugin #{::Knife::Softlayer::VERSION}" unless defined? USER_AGENT

      # :nodoc:
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'fog/softlayer'
            require 'net/ssh'
            require 'net/ssh/multi'
            require 'chef/monkey_patches/net-ssh-multi'
            require 'readline'
            require 'chef/exceptions'
            require 'chef/search/query'
            require 'chef/mixin/command'
            require 'chef/mixin/shell_out'
            require 'mixlib/shellout'
            require 'chef/json_compat'
          end

          option :softlayer_credential_file,
                 :long => "--softlayer-credential-file FILE",
                 :description => "File containing SoftLayer credentials as used by `softlayer_api` Ruby gem.",
                 :proc => Proc.new { |key| Chef::Config[:knife][:softlayer_credential_file] = key }

          option :softlayer_username,
                 :short => "-U USERNAME",
                 :long => "--softlayer-username KEY",
                 :description => "Your SoftLayer Username",
                 :proc => Proc.new { |key| Chef::Config[:knife][:softlayer_access_key_id] = key }

          option :softlayer_api_key,
                 :short => "-K SECRET",
                 :long => "--softlayer-api-key SECRET",
                 :description => "Your SoftLayer API Key",
                 :proc => Proc.new { |key| Chef::Config[:knife][:softlayer_secret_access_key] = key }
        end
      end

      ##
      # Returns a connection to a SoftLayer API Service Endpoint.
      # @param [Symbol] service
      # @return [SoftLayer::Service]
      def connection(service=:compute)
        self.send(service)
      end

      def compute
        @compute_connection ||= Fog::Compute.new(
            :provider => :softlayer,
            :softlayer_username => Chef::Config[:knife][:softlayer_username],
            :softlayer_api_key => Chef::Config[:knife][:softlayer_api_key],
            :softlayer_default_datacenter => Chef::Config[:knife][:softlayer_default_datacenter],
            :softlayer_default_domain => Chef::Config[:knife][:softlayer_default_domain],
        )
      end

      def network
        @network_connection ||= Fog::Network.new(
          :provider => :softlayer,
          :softlayer_username => Chef::Config[:knife][:softlayer_username],
          :softlayer_api_key => Chef::Config[:knife][:softlayer_api_key],
        )
      end

      ##
      # Locates a config value.
      # @param [String] key
      # @return [String]
      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

      ##
      # A CLI output formatting wrapper.
      # @param [String] label
      # @param [String] value
      # @param [Symbol] color
      # @return [String]
      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

    end
  end
end
