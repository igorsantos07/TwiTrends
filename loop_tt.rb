ROOT_FOLDER = '/home/igoru/scripts/twitrends/'
LAST_RUN_FILENAME = ROOT_FOLDER+'last-run.time'
LAST_TWEET_FILENAME = ROOT_FOLDER+'last-tweet.time'
LOG_FILE = ROOT_FOLDER+'tt.log'
TIME_OF_EACH_LOOP = 60
TIME_OF_EACH_TWEET = 60*20 - 15 #15 seconds to let tt.rb run and then change the time of the file

def write_time_to_log
		diff = (File.exist?(LAST_TWEET_FILENAME))? Time.now.to_i - File.new(LAST_TWEET_FILENAME).ctime.to_i : 'zzz'
		File.open(LOG_FILE, 'a') {|f| f.write(diff.to_s+' - '+Time.now.to_s+"\n") }
end

class File
	def File.touch filename
		File.new(filename, 'w')
		true
	end
end

def diff_of_file_from_now file
	Time.now.to_i - File.new(file).ctime.to_i
end

while true
  File.open(LAST_RUN_FILENAME, 'w') {|f| f.write(Time.now.to_i.to_s) }

	write_time_to_log
  if (!File.exist?(LAST_TWEET_FILENAME) or diff_of_file_from_now(LAST_TWEET_FILENAME) >= TIME_OF_EACH_TWEET)
    system "ruby '#{ROOT_FOLDER}tt.rb' 2>&1 >>'#{LOG_FILE}'"
    File.touch LAST_TWEET_FILENAME
  end

  sleep TIME_OF_EACH_LOOP
end