require 'twitter'
twitter = Twitter::Client.new
puts twitter.local_trends(455825).inspect
