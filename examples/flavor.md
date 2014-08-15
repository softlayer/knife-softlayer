### Flavor examples

These examples all assume you have set your SoftLayer username and api key in `~/.chef/knife.rb` like this:

```ruby
knife[:softlayer_username] = 'example_user'
knife[:softlayer_api_key]  = '1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a'
```
  
#### List available flavors

```sh
user@localhost> knife softlayer flavor list
 +-----------+-----+-------+--------------------------------------------------+
 | id        | cpu | ram   | disk                                             |
 +-----------+-----+-------+--------------------------------------------------+
 | m1.tiny   | 2   | 1024  | [{"device"=>0, "diskImage"=>{"capacity"=>25}}]   |
 +-----------+-----+-------+--------------------------------------------------+
 | m1.small  | 2   | 2048  | [{"device"=>0, "diskImage"=>{"capacity"=>100}}]  |
 +-----------+-----+-------+--------------------------------------------------+
 | m1.medium | 4   | 4096  | [{"device"=>0, "diskImage"=>{"capacity"=>500}}]  |
 +-----------+-----+-------+--------------------------------------------------+
 | m1.large  | 8   | 8192  | [{"device"=>0, "diskImage"=>{"capacity"=>750}}]  |
 +-----------+-----+-------+--------------------------------------------------+
 | m1.xlarge | 16  | 16384 | [{"device"=>0, "diskImage"=>{"capacity"=>1000}}] |
 +-----------+-----+-------+--------------------------------------------------+
NOTICE: 
'flavors' provided here for convenience; SoftLayer allows you to choose a configuration a la carte.
For a full list of available instance options use --all with the `knife softlayer flavor list` subcommand.
```

#### List available *a la carte* options

```sh
user@localhost> knife softlayer flavor list --all
| CORES                       | RAM             | DISK             | OS                       | NETWORK [MBS]  | DATACENTER 
| ==========                  | ==========      | ==========       | ==========               | ==========     | ========== 
|  1 x 2.0 GHz Core           |  1024 [1 GB]    |  1,000 GB (SAN)  |  CENTOS_LATEST           |  10            |  ams01     
|  2 x 2.0 GHz Cores          |  2048 [2 GB]    |  1,000 GB (SAN)  |  CENTOS_LATEST_64        |  100           |  dal01     
|  4 x 2.0 GHz Cores          |  4096 [4 GB]    |  1,000 GB (SAN)  |  CENTOS_LATEST_32        |  1000          |  dal05     
|  8 x 2.0 GHz Cores          |  6144 [6 GB]    |  1,000 GB (SAN)  |  CENTOS_6_64             |                |  dal06     
|  12 x 2.0 GHz Cores         |  8192 [8 GB]    |  1,500 GB (SAN)  |  CENTOS_6_32             |                |  hkg02     
|  16 x 2.0 GHz Cores         |  12288 [12 GB]  |  1,500 GB (SAN)  |  CENTOS_5_64             |                |  lon02     
|  Private 1 x 2.0 GHz Core   |  16384 [16 GB]  |  1,500 GB (SAN)  |  CENTOS_5_32             |                |  sea01     
|  Private 2 x 2.0 GHz Cores  |  32768 [32 GB]  |  1,500 GB (SAN)  |  CLOUDLINUX_LATEST       |                |  sjc01     
|  Private 4 x 2.0 GHz Cores  |  49152 [48 GB]  |  10 GB (SAN)     |  CLOUDLINUX_LATEST_64    |                |  sng01     
|  Private 8 x 2.0 GHz Cores  |  65536 [64 GB]  |  10 GB (SAN)     |  CLOUDLINUX_LATEST_32    |                |  tor01     
|                             |                 |  10 GB (SAN)     |  CLOUDLINUX_6_64         |                |  wdc01     
|                             |                 |  10 GB (SAN)     |  CLOUDLINUX_6_32         |                |            
|                             |                 |  100 GB (LOCAL)  |  CLOUDLINUX_5_64         |                |            
|                             |                 |  100 GB (LOCAL)  |  CLOUDLINUX_5_32         |                |            
|                             |                 |  100 GB (SAN)    |  DEBIAN_LATEST           |                |            
|                             |                 |  100 GB (SAN)    |  DEBIAN_LATEST_64        |                |            
|                             |                 |  100 GB (SAN)    |  DEBIAN_LATEST_32        |                |            
|                             |                 |  100 GB (SAN)    |  DEBIAN_7_64             |                |            
|                             |                 |  100 GB (SAN)    |  DEBIAN_7_32             |                |            
|                             |                 |  125 GB (SAN)    |  DEBIAN_6_64             |                |            
# LIST HAS BEEN TRUNCATED FOR THIS EXAMPLE
```