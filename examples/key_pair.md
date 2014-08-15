### Key Pair Examples

These examples all assume you have set your SoftLayer username and api key in `~/.chef/knife.rb` like this:

```ruby
knife[:softlayer_username] = 'example_user'
knife[:softlayer_api_key]  = '1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a'
```
  
#### Create a Key Pair

```sh
user@localhost> knife softlayer key pair create
Enter the label for this key pair: 
```

```sh
user@localhost> knife softlayer key pair create
Enter the label for this key pair: my-new-key-pair
Enter path to the public key:
```

```sh
user@localhost> knife softlayer key pair create
Enter the label for this key pair: my-new-key-pair
Enter path to the public key: /Users/user/.ssh/my_key_rsa.pub
```

```sh
user@localhost> knife softlayer key pair create
Enter the label for this key pair: my-new-key-pair
Enter path to the public key: /Users/user/.ssh/my_key_rsa.pub
Key pair successfully created.  Provisioning may take a few minutes to complete.
Key pair ID is:  31246
```



  
#### List Key Pairs

```sh
user@localhost> knife softlayer key pair list
+-------+------------------+---------------------------+-------------+
| id    | label            | create_date               | modify_date |
+-------+------------------+---------------------------+-------------+
| 30846 | Key1             | 2014-01-01T17:05:33-05:00 |             |
+-------+------------------+---------------------------+-------------+
| 30946 | Key2             | 2014-02-24T11:36:43-05:00 |             |
+-------+------------------+---------------------------+-------------+
| 31046 | Key3             | 2014-03-24T11:35:59-05:00 |             |
+-------+------------------+---------------------------+-------------+
| 31146 | Key4             | 2014-04-10T14:48:35-05:00 |             |
+-------+------------------+---------------------------+-------------+
| 31246 | my-new-key-pair  | 2014-05-29T11:53:17-05:00 |             |
+-------+------------------+---------------------------+-------------+
```