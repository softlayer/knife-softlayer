#
# Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
# © Copyright IBM Corporation 2014.
#
# LICENSE: Apache 2.0 (http://www.apache.org/licenses/)
#

require 'chef/knife'
require 'knife-softlayer/version'

class Chef
  class Knife
    module SoftlayerBase

      USER_AGENT = "Chef Knife Softlayer Plugin #{::Knife::Softlayer::VERSION}"

      # :nodoc:
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'softlayer_api'
            require 'readline'
            require 'chef/json_compat'
            require 'net/ssh'
            require 'net/ssh/multi'
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
      def connection(service=:cci)
        SoftLayer::Service.new(
            SoftlayerBase.send(service),
            :username => Chef::Config[:knife][:softlayer_username],
            :api_key => Chef::Config[:knife][:softlayer_api_key],
            :user_agent => USER_AGENT
        )
      end

      ##
      # Returns identifier string for the SoftLayer Virtual Guest service.
      # @return [String]
      def self.cci
        'SoftLayer_Virtual_Guest'
        end

      ##
      # Returns identifier string for the SoftLayer Product Package service.
      # @return [String]
      def self.package
        'SoftLayer_Product_Package'
      end

      ##
      # Returns identifier string for the SoftLayer Product Order service.
      # @return [String]
      def self.order
        'SoftLayer_Product_Order'
      end

      ##
      # Returns identifier string for the SoftLayer Subnet Ordering service.
      # @return [String]
      def self.subnet
        'SoftLayer_Container_Product_Order_Network_Subnet'
      end

      ##
      # Returns identifier string for the SoftLayer User Account service.
      # @return [String]
      def self.account
        'SoftLayer_Account'
      end

      ##
      # Returns identifier string for the SoftLayer Global IP service.
      # @return [String]
      def self.global_ip
        'SoftLayer_Network_Subnet_IpAddress_Global'
      end

      ##
      # Returns id of a particular SoftLayer ordering package.
      # @return [String]
      def self.non_server_package_id
        0 # this package contains everything that isn't a server on the SoftLayer API
      end

      ##
      # Queries the SoftLayer API and returns the "category code" required for ordering a Global IPv4 address.
      # @return [Integer]
      def self.global_ipv4_cat_code
        SoftLayer::Service.new(
            SoftlayerBase.send(:package),
            :username => Chef::Config[:knife][:softlayer_username],
            :api_key => Chef::Config[:knife][:softlayer_api_key],
            :user_agent => USER_AGENT
        ).object_with_id(non_server_package_id).object_mask('isRequired', 'itemCategory').getConfiguration.map do |item|
          item['itemCategory']['id'] if item['itemCategory']['categoryCode'] == 'global_ipv4'
        end.compact.first
      end

      ##
      # Queries the SoftLayer API and returns the "price code" required for ordering a Global IPv4 address.
      # @return [Integer]
      def self.global_ipv4_price_code
        SoftLayer::Service.new(
            SoftlayerBase.send(:package),
            :username => Chef::Config[:knife][:softlayer_username],
            :api_key => Chef::Config[:knife][:softlayer_api_key],
            :user_agent => USER_AGENT
        ).object_with_id(non_server_package_id).object_mask('id', 'item.description', 'categories.id').getItemPrices.map do |item|
          item['id'] if item['categories'][0]['id'] == SoftlayerBase.global_ipv4_cat_code
        end.compact.first
      end

      ##
      # Constructs an order required for purchasing a Global IPv4 address.
      # @return [Hash]
      def self.build_global_ipv4_order
        {
            "complexType" => SoftlayerBase.subnet,
            "packageId" => non_server_package_id,
            "prices" => [{"id"=>SoftlayerBase.global_ipv4_price_code}],
            "quantity" => 1
        }
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
