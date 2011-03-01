ROOT_FOLDER = '/home/igoru/scripts/twitrends/'
LAST_RUN_FILENAME = ROOT_FOLDER+'last-run.time'
LAST_TWEET_FILENAME = ROOT_FOLDER+'last-tweet.time'
LOG_FILE = ROOT_FOLDER+'tt.log'
EACH_LOOP = 60
EACH_TWEET = 60*20

while true
  File.open(LAST_RUN_FILENAME, 'w') {|f| f.write(Time.now.to_i.to_s) }

  if (!File.exist?(LAST_TWEET_FILENAME) or Time.now.to_i - File.new(LAST_TWEET_FILENAME).atime.to_i >= EACH_TWEET)
    system "ruby '#{ROOT_FOLDER}tt.rb' 2>&1 >>'#{LOG_FILE}'"
    File.new(LAST_TWEET_FILENAME, 'w')
  end

  sleep EACH_LOOP
end