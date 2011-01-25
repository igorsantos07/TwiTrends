require 'sqlite3'
require 'yaml'
require 'twitter'

db = SQLite3::Database.new((File.exists? 'stats.db')? 'stats.db' : $LOAD_PATH[0]+'/stats.db')

yaml_file = (File.exists? 'accounts.yaml')? 'accounts.yaml' : $LOAD_PATH[0]+'/accounts.yaml'
YAML::load_file(yaml_file).each_key do |account|
  acc_id = if db.get_first_value('SELECT COUNT(*) FROM accounts WHERE name=?', account) == '0'
    db.execute 'INSERT INTO accounts (name) VALUES (?)', account
    db.last_insert_row_id
  else
    db.execute 'SELECT id FROM accounts WHERE name=?', account
  end

  followers = Twitter.user(account).followers_count
  db.execute 'INSERT INTO stats (account, date, followers) VALUES (?,?,?)', acc_id, Time.now.to_i, followers
  puts "Now, #{account}(#{acc_id}) has #{followers} follow#{'s' if followers > 1}."
end