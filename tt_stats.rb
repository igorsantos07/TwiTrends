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
YAML::load_file(yaml_file).each_key do |account|
  acc_id = if db.get_first_value('SELECT COUNT(*) FROM accounts WHERE name=?', account) == '0'
    db.execute 'INSERT INTO accounts (name) VALUES (?)', account
    db.last_insert_row_id
  else
    db.execute 'SELECT id FROM accounts WHERE name=?', account
  end

	followers = ''
	got_error = false
	while followers.empty? and (Time.now - start) < 60 * 60 * 12 do # gives up after 12 hours
		begin
			print 'Trying to connect again. ' if got_error
			followers = Twitter.user(account).followers_count
		rescue SocketError => e
			puts ' Oops! Are you connected? Trying again in 10 seconds.'
			got_error = true
			sleep 10
		end
	end

	db.execute 'INSERT INTO stats (account, date, followers) VALUES (?,?,?)', acc_id, Time.now.to_i, followers unless $debug
  puts "Now, #{account}(#{acc_id}) has #{followers} follow#{'s' if followers > 1}."
end