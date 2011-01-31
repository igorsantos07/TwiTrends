start = Time.now

require 'twitter'

if (ARGV[0] == '-t')
	$debug = false
	puts "Tweeting for real. If I should't do that, CTRL+C NOW! And then, run me again without -t flag, you bastard."
else
	$debug = true
	puts "Entering debug mode (a.k.a. won't tweet for real). If you want to tweet, use -t flag and be happy."
end

$format = '[%s] %s' # [time] Trending topics

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

	trends = ''
	got_error = false
	while trends.empty? and (Time.now - start) < 60 * 15 do # gives up after 15 minutes
		begin
			print 'Trying to connect again. ' if got_error
			trends = twitter.local_trends(acc['woeid'])
		rescue SocketError => e
			puts ' Oops! Are you connected? Trying again in 10 seconds.'
			got_error = true
			sleep 10
		end
	end
  puts trends.inspect

	def concat trends, plus=0
		trends.collect { |v| i = trends.index(v)+1+plus; "#{i.to_s}. #{v}" } .join(' || ')
	end

	now  = Time.now
	time = now.hour.to_s+'h'+('%02d'%now.min)

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