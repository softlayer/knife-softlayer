### VLAN examples

These examples all assume you have set your SoftLayer username and api key in `~/.chef/knife.rb` like this:

```ruby
knife[:softlayer_username] = 'example_user'
knife[:softlayer_api_key]  = '1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a'
```
  
#### Create a new VLAN

```sh
user@localhost> knife softlayer vlan create
Enter a vlan name:
```

```sh
user@localhost> knife softlayer vlan create
Enter a vlan name: my-new-vlan
Enter a datacenter name: 
```

```sh
user@localhost> knife softlayer vlan create
Enter a vlan name: my-new-vlan
Enter a datacenter name: wdc01
Enter a router hostname: 
```

```sh
user@localhost> knife softlayer vlan create
Enter a vlan name: my-new-vlan
Enter a datacenter name: wdc01
Enter a router hostname: bcr05a.wdc01
Enter a network space:[PUBLIC]
```

```sh
user@localhost> knife softlayer vlan create
Enter a vlan name: my-new-vlan
Enter a datacenter name: wdc01
Enter a router hostname: bcr05a.wdc01
Enter a network space:[PUBLIC] PRIVATE # routers that start with bcr are for private VLANS; fcr are for public VLANS
VLAN successfully created.  Provisioning may take a few minutes to complete.
```

#### List VLANS

```sh
user@localhost> knife softlayer vlan list
+--------+----------------------+--------------+---------------+--------------+
| id     | name                 | datacenter   | network_space | router       |
+--------+----------------------+--------------+---------------+--------------+
| 379384 | [none]               | Washington 1 | PUBLIC        | fcr02.wdc01  |
+--------+----------------------+--------------+---------------+--------------+
| 379386 | [none]               | Washington 1 | PRIVATE       | bcr02.wdc01  |
+--------+----------------------+--------------+---------------+--------------+
| 563298 | my-new-vlan          | Washington 1 | PRIVATE       | bcr02.wdc01  |
+--------+----------------------+--------------+---------------+--------------+
| 339652 | [none]               | San Jose 1   | PUBLIC        | fcr01a.sjc01 |
+--------+----------------------+--------------+---------------+--------------+
| 339654 | [none]               | San Jose 1   | PRIVATE       | bcr01a.sjc01 |
+--------+----------------------+--------------+---------------+--------------+
| 557984 | [none]               | Dallas 5     | PUBLIC        | fcr02a.dal05 |
+--------+----------------------+--------------+---------------+--------------+
| 557986 | [none]               | Dallas 5     | PRIVATE       | bcr02a.dal05 |
+--------+----------------------+--------------+---------------+--------------+
```

#### Show a particular VLAN

```sh
user@localhost> knife softlayer vlan show 563298
ID: 563298
Name: my-new-vlan
Datacenter: wdc01
Network Space: PRIVATE
Router: bcr02.wdc01
Subnets:
  +--------+------+---------------+---------------+---------------+---------+------------+------------+
  | id     | cidr | gateway_ip    | network_id    | broadcast     | type    | datacenter | ip_version |
  +--------+------+---------------+---------------+---------------+---------+------------+------------+
  | 572522 | 30   | 10.32.181.241 | 10.32.181.240 | 10.32.181.243 | PRIMARY | wdc01      | 4          |
  +--------+------+---------------+---------------+---------------+---------+------------+------------+
```
