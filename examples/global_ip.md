### Global IP examples

These examples all assume you have set your SoftLayer username and api key in `~/.chef/knife.rb` like this:

```ruby
knife[:softlayer_username] = 'example_user'
knife[:softlayer_api_key]  = '1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a'
```
  
#### List global ip addresses

```sh
user@localhost> knife softlayer global ip list
 +-----------------+-----------------+
 | address         | destination     |
 +-----------------+-----------------+
 | 108.168.254.93  | 173.192.218.117 |
 +-----------------+-----------------+
 | 108.168.254.96  | NOT ROUTED      |
 +-----------------+-----------------+
 | 108.168.254.168 | NOT ROUTED      |
 +-----------------+-----------------+ 	
```