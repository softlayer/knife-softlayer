# Knife::Softlayer

A knife plugin for launching and bootstrapping instances in the IBM SoftLayer cloud.

## Installation

Add this line to your application's Gemfile:

    gem 'knife-softlayer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-softlayer

## Usage

See `knife softlayer --help` for more information.

EXAMPLES:


```bash
# look at some options
user@local> knife softlayer flavor list [--all]
```

```bash
# the minimum number of pieces of flare
user@local> knife softlayer server create --hostname test --domain example.com --flavor tiny
```

```bash
# being sort of specific about things
user@local> knife softlayer server create -H test -D example.com \
--block-storage 0:25,2:100,5:1000 \ # device:GB, device:GB, ...
--network-interface-speed 1000 \
--cores 8 \
--ram 49152 \
--os-code REDHAT_6_64 \
--datacenter ams01 \
--node-name random-node-name \
--assign-global-ip <existingGlobalIpv4Address> \
--run-list 'recipe[apt],recipe[git],recipe[rbenv],recipe[memcached],recipe[redis]'
```

#### Legal stuff
Use of this software requires runtime dependencies.  Those dependencies and their respective software licenses are listed below.

* [net-ssh](https://github.com/net-ssh/net-ssh/) - LICENSE: [MIT](https://github.com/net-ssh/net-ssh/blob/master/LICENSE.txt)
* [softlayer_api](https://github.com/softlayer/softlayer-api-ruby-client) - LICENSE: [MIT](https://github.com/softlayer/softlayer-api-ruby-client/blob/master/LICENSE.textile)
* [knife-windows](https://github.com/opscode/knife-windows) - LICENSE: [Apache v2](https://github.com/opscode/knife-windows/blob/master/LICENSE)


--
> Author:: Matt Eldridge (<matt.eldridge@us.ibm.com>)
>
> © Copyright IBM Corporation 2014.
>
> LICENSE: Apache 2.0 (http://www.apache.org/licenses/)

