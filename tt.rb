require 'twitter'
require 'accounts'

$accounts.each do |acc|
  puts "Getting Trending Topics for WOEID #{acc[:woeid]} and tweeting to #{acc[:username]}..."

  Twitter.configure do |c|
    c.consumer_key       = acc[:consumer_key]
    c.consumer_secret    = acc[:consumer_secret]
    c.oauth_token        = acc[:oauth_key]
    c.oauth_token_secret = acc[:oauth_secret]
  end

  twitter = Twitter::Client.new

  trends = twitter.local_trends(acc[:woeid])
  puts trends.inspect
  puts ''
end