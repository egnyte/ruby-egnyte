Ruby Egnyte
===========

Mainted by: [Attachments.me](https://attachments.me)

A feature-rich Ruby client for [Egnyte Version 1 API](https://developers.egnyte.com/docs).

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
folder = @client.folder('/Shared/Documents/banana')
folder.delete
```

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
