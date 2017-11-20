Ruby Egnyte
===========

This SDK is no longer supported by Egnyte. It continues to be available as-is and pull requests will be merged, but no support  will be provided.
--------

A feature-rich Ruby client for the [Egnyte API](https://developers.egnyte.com/docs).  

Special thanks to the folks at Attachments.me and Yesware, Inc. who got this library off to a great start.

NOTE: THIS LIBRARY IS CURRENTLY UNDER DEVELOPMENT TO EXTEND SUPPORT TO ALL AVAILABLE ENDPOINTS.  WHEN THE CURRENT WORK IS COMPLETE, THE VERSION WILL BE BUMPED TO 0.2.0.

Authentication
--------

* Create a session object with your [Egnyte API Key](https://developers.egnyte.com/)
* Create an authorize url and direct a user to it, to retrieve an access_token for their account.

```ruby
require 'egnyte'

session = Egnyte::Session.new({
    key: 'api_key',
    domain: 'egnyte_domain'
})
session.authorize_url('https://127.0.0.1/oauth2callback')

# direct the user to the authorize URL generated,
# the callback provided will be executed with an access token.

session.create_access_token('the_access_token_returned')
```
* Create a client, with the authenticated session.

```ruby
@client = Egnyte::Client.new(session)
```

The client initialized, we can start interacting with the Egnyte API.

Folders
------

* Fetching a folder

```ruby
folder = @client.folder('/Shared')
p folder.name # outputs 'Shared'.
```

* Listing files in a folder.

```ruby
@client.folder('/Shared/Documents/').files.each {|f| p f.name}
# outputs "IMG_0440.JPG", "IMG_0431.JPG"
```

* Creating a folder.

```ruby
new_folder = @client.folder('/Shared/Documents/').create('banana')
p new_folder.path # a new folder was created /Shared/Documents/banana
```

* Deleting a folder.

```ruby
folder = @client.folder('/Shared/Documents/banana')
folder.delete
```

Files
-----

* Fetching a file

```ruby
file = @client.file('/Shared/example.txt')
p file.name # example.txt.
```

* Deleting a file.

```ruby
@client.file('/Shared/example.txt').delete
```

* Uploading a file.

```ruby
local_path = "./LICENSE.txt"
filename = "LICENSE.txt"

folder = @client.folder('Shared/Documents/')
File.open( local_path ) do |data|
 folder.upload(filename, data)
end
```

* Downloading a file.

```ruby
file = @client.file('/Shared/Documents/LICENSE.txt')
file.download
```

Contributing
-----------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
