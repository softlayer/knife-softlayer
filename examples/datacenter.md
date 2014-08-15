### Datacenter Examples

These examples all assume you have set your SoftLayer username and api key in `~/.chef/knife.rb` like this:

```ruby
knife[:softlayer_username] = 'example_user'
knife[:softlayer_api_key]  = '1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a'
```
  
#### List all available datacenters

```sh
user@localhost> knife softlayer datacenter list
 +-------+--------------+
 | name  | long_name    |
 +-------+--------------+
 | ams01 | Amsterdam 1  |
 +-------+--------------+
 | wdc03 | Ashburn 3    |
 +-------+--------------+
 | dal01 | Dallas 1     |
 +-------+--------------+
 | dal02 | Dallas 2     |
 +-------+--------------+
 | dal04 | Dallas 4     |
 +-------+--------------+
 | dal05 | Dallas 5     |
 +-------+--------------+
 | dal06 | Dallas 6     |
 +-------+--------------+
 | dal07 | Dallas 7     |
 +-------+--------------+
 | hkg02 | Hong Kong 2  |
 +-------+--------------+
 | hou02 | Houston 2    |
 +-------+--------------+
 | lon02 | London 2     |
 +-------+--------------+
 | sjc01 | San Jose 1   |
 +-------+--------------+
 | sea01 | Seattle      |
 +-------+--------------+
 | sng01 | Singapore 1  |
 +-------+--------------+
 | tor01 | Toronto 1    |
 +-------+--------------+
 | wdc01 | Washington 1 |
 +-------+--------------+

```

#### Show a particular datacenter
```sh
user@localhost> knife softlayer datacenter show tor01
Long Name: Toronto 1
Name: tor01
Routers:
  +--------------+--------+
  | hostname     | id     |
  +--------------+--------+
  | bcr01a.tor01 | 266212 |
  +--------------+--------+
  | fcr01a.tor01 | 266412 |
  +--------------+--------+
  
user@localhost> knife softlayer datacenter show wdc01
Long Name: Washington 1
Name: wdc01
Routers:
  +--------------+--------+
  | hostname     | id     |
  +--------------+--------+
  | bcr01.wdc01  | 16358  |
  +--------------+--------+
  | bcr02.wdc01  | 40379  |
  +--------------+--------+
  | bcr03a.wdc01 | 85816  |
  +--------------+--------+
  | bcr04a.wdc01 | 180611 |
  +--------------+--------+
  | bcr05a.wdc01 | 235754 |
  +--------------+--------+
  | fcr01.wdc01  | 16357  |
  +--------------+--------+
  | fcr02.wdc01  | 40378  |
  +--------------+--------+
  | fcr03a.wdc01 | 85814  |
  +--------------+--------+
  | fcr04a.wdc01 | 180610 |
  +--------------+--------+
  | fcr05a.wdc01 | 235748 |
  +--------------+--------+

```
