require 'twitter'
$debug = false

$format = '[%s] %s' # [time] Trending topics

now  = Time.now
time = ('%2d'%now.hour)+'h'+('%2d'%now.min)

YAML::load_file('accounts.yaml').each_pair do |title, acc|
  print "Getting Trending Topics and tweeting to #{title}..."

  Twitter.configure do |c|
    c.consumer_key       = acc['consumer_key']
    c.consumer_secret    = acc['consumer_secret']
    c.oauth_token        = acc['oauth_key']
    c.oauth_token_secret = acc['oauth_secret']
  end

  twitter = Twitter::Client.new

  trends = twitter.local_trends(acc['woeid'])
  puts trends.inspect

	[
		$format % [time, trends[0..4].join(' | ')],
		$format % [time, trends[5..9].join(' | ')]
	].each do |tweet|
		if $debug
			puts "Tweet >> "+tweet
		else
			twitter.update tweet
		end
	end

	puts ''
end