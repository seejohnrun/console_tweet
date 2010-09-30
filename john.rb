require 'rubygems'
require 'twitter_oauth'

client = TwitterOAuth::Client.new(:consumer_key => 'MvVdCyl6xCVtEUVdcp4rw', :consumer_secret => '3xD0oy47WhWYUIBCU6QzcIBqsrAAL3KnYWKhd6ALk2k')
request_token = client.request_token

puts "URL: #{request_token.authorize_url}"

print 'token? '
code = gets.chomp

puts "got code: #{code}"

access_token = client.authorize(request_token.token, request_token.secret, :oauth_verifier => code)

puts "authorized? #{client.authorized?}"
puts "access_token: #{access_token}"
