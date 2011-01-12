require 'twitter'
require 'accounts'

twitter = Twitter::Client.new

$accounts.each do |acc|
  puts "Getting Trending Topics for WOEID #{acc[:woeid]} and tweeting to #{acc[:username]}..."
  trends = twitter.local_trends(455825)
  puts trends.inspect
  puts ''
end