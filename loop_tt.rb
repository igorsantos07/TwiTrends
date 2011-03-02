ROOT_FOLDER = '/home/igoru/scripts/twitrends/'
LAST_RUN_FILENAME = ROOT_FOLDER+'last-run.time'
LAST_TWEET_FILENAME = ROOT_FOLDER+'last-tweet.time'
LOG_FILE = ROOT_FOLDER+'tt.log'
EACH_LOOP = 60
EACH_TWEET = 60*20 - 15 #15 seconds to let tt.rb run and then change the time of the file

while true
  File.open(LAST_RUN_FILENAME, 'w') {|f| f.write(Time.now.to_i.to_s) }

  diff = (File.exist?(LAST_TWEET_FILENAME))? Time.now.to_i - File.new(LAST_TWEET_FILENAME).ctime.to_i : 'zzz'
  if (!File.exist?(LAST_TWEET_FILENAME) or Time.now.to_i - File.new(LAST_TWEET_FILENAME).ctime.to_i >= EACH_TWEET)
    system "echo '#{diff} - "+Time.now.to_s+"' >>'#{LOG_FILE}'"
    system "ruby '#{ROOT_FOLDER}tt.rb' -t 2>&1 >>'#{LOG_FILE}'"
    File.new(LAST_TWEET_FILENAME, 'w')
  else
    system "echo '#{diff}' >>'#{LOG_FILE}'"
  end

  sleep EACH_LOOP
end