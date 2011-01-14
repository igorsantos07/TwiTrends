require 'twitter'
$debug = true

$format = '[%s] %s' # [time] Trending topics

now  = Time.now
time = now.hour.to_s+'h'+('%02d'%now.min)

yaml_file = (File.exists? 'accounts.yaml')? 'accounts.yaml' : $LOAD_PATH[0]+'/accounts.yaml'
YAML::load_file(yaml_file).each_pair do |title, acc|
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

	def concat trends, plus=0
		trends.collect { |v| i = trends.index(v)+1+plus; "#{i.to_s}. #{v}" } .join(' || ')
	end

	[
		$format % [time, concat(trends[5..9],5) ],
		$format % [time, concat(trends[0..4]) ]
	].each do |tweet|
		if $debug
			puts "Tweet (#{tweet.length} chars) >> "+tweet
		else
			twitter.update tweet
			twitter.update "d igorgsantos Tweet over 140 chars (#{tweet.length})! \"#{tweet[0..80]}\"" if tweet.length > 140
		end
	end

	puts ''
end
