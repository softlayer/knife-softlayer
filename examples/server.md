### Server Examples

These examples all assume you have set your SoftLayer username and api key in `~/.chef/knife.rb` like this:

```ruby
knife[:softlayer_username] = 'example_user'
knife[:softlayer_api_key]  = '1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a'
```
  
#### Create server and bootstrap as a chef node

Create a server using an image, a flavor, assign an existing global ip address, and inject two ssh keys.

```sh
user@localhost> knife softlayer server create --image-id 23f7f05f-3657-4330-8772-329ed2e816bc --assign-global-ip 108.168.254.41 --ssh-keys 12345 23456 --hostname web --domain ibm.com --flavor m1.tiny --run-list 'recipe[redis],recipe[rbenv],recipe[apt]' -i /Users/user/.ssh/my_private_key_rsa  
```

Create a server, provision a new global ip address and assign it to the server, tag both the chef node and the SoftLayer server with the passed tags. 

```sh
user@localhost> knife softlayer server create --new-global-ip v4 --tags job=task,private=true --hostname web --domain ibm.com --flavor m1.tiny --run-list 'recipe[redis],recipe[rbenv],recipe[apt]' --ssh-keys 12345 -i /Users/user/.ssh/my_private_key_rsa
```

Create a server located in specific public and private VLANS.

```sh
user@localhost> knife softlayer server create --vlan 12345 --private-vlan 23456 --hostname web --domain ibm.com --flavor m1.tiny --run-list 'recipe[redis],recipe[rbenv],recipe[apt]' --ssh-keys 12345 -i /Users/user/.ssh/my_private_key_rsa --new-global-ip v4 --tags job=task,private=true
```

Create a server specifying options from a JSON file.

```sh
user@localhost> cat /Users/user/bootstrap.json
{
  "hostname": "web",
  "domain": "ibm.com",
  "flavor": "m1.xlarge",
  "run-list": "recipe[redis],recipe[rbenv],recipe[apt]",
  "ssh-keys": "73148",
  "identity-file": "/Users/user/.ssh/my_softlayer_key_rsa",
  "image-id": "23f7f05f-3657-4330-8772-329ed2e816bc"
}

user@localhost> knife softlayer server create --from-file /Users/user/bootstrap.json

# options file + additional arguments
user@localhost> knife softlayer server create --from-file /Users/user/bootstrap.json --tags job=task,private=true
```

Other options.

```sh
user@localhost> knife softlayer server create --help
# There are a lot...
```

#### Destroy a server and its chef node and client

Use the node name as an identifier.

```sh
user@localhost> knife softlayer server destroy --node-name some-node-name
Decommissioning SoftLayer VM, this may take a few minutes.
WARNING: Deleted node some-node-name
Chef node successfully deleted.
WARNING: Deleted client some-node-name
Chef client successfully deleted.
SoftLayer VM successfully deleted. You are no longer being billed for this instance.
```

Use the public ip address as an identifier 

```sh
user@localhost> knife softlayer server destroy --ip-address 33.33.33.33
Decommissioning SoftLayer VM, this may take a few minutes.
WARNING: Deleted node 5849421
Chef node successfully deleted.
WARNING: Deleted client 5849421
Chef client successfully deleted.
SoftLayer VM successfully deleted. You are no longer being billed for this instance.
```