start = Time.now

require 'sqlite3'
require 'yaml'
require 'twitter'

if (ARGV[0] == '-t')
	$debug = false
	puts "Saving data for real. If I should't do that, CTRL+C NOW! And then, run me again without -t flag, you bastard."
else
	$debug = true
	puts "Entering debug mode (a.k.a. won't save data for real). If you want to tweet, use -t flag and be happy."
end

db = SQLite3::Database.new((File.exists? 'stats.db')? 'stats.db' : $LOAD_PATH[0]+'/stats.db')

yaml_file = (File.exists? 'accounts.yaml')? 'accounts.yaml' : $LOAD_PATH[0]+'/accounts.yaml'
YAML::load_file(yaml_file).each_pair do |account,data|
  acc_id = if db.get_first_value('SELECT COUNT(*) FROM accounts WHERE name=?', account) == 0
    db.execute 'INSERT INTO accounts (name,color) VALUES (?,?)', account, data['account']['color']
    db.last_insert_row_id
  else
    db.execute 'SELECT id FROM accounts WHERE name=?', account
  end

	followers = nil
	got_error = false
	while followers.nil? and (Time.now - start) < 60 * 60 * 12 do # gives up after 12 hours
		begin
			print 'Trying to connect again. ' if got_error
      user = Twitter.user account
      followers = user.followers_count
      if !followers then followers = 1 end
      tweets = user.statuses_count
		rescue SocketError => e
			puts ' Oops! Are you connected? Trying again in 10 seconds.'
			got_error = true
			sleep 10
		end
	end

  if (!$debug)
    puts "'INSERT INTO stats (account, date, followers) VALUES (?,?,?)', #{acc_id}, Time.now.to_i, #{followers}"
    db.execute 'INSERT INTO stats (account, date, followers) VALUES (?,?,?)', acc_id, Time.now.to_i, followers
    db.execute 'UPDATE accounts SET tweets=? WHERE id=?', tweets, acc_id
  end
  puts "Now, #{account}(#{acc_id}) has #{followers} follower#{'s' if followers > 1} and #{tweets} tweet#{'s' if tweets > 1}."
end
