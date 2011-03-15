require 'rubygems'
require 'twitter'

class Twitrends

  def accounts_file= path
    if File.file?(path) and File.readable?(path)
      @accounts_file = path
      @accounts = YAML::load_file path
    else
      raise ArgumentError, "accounts_file '#{path}' is not readable!"
    end
  end

  def initialize accounts_file_path, verbose = false
    self.accounts_file= accounts_file_path
    @verbose = verbose
    @format = '[%s] %s' # [time] Trending topics
  end

  # If the argument is false or not set, won't tweet. Only show output to know it's working properly.
  def tweet for_real = false
    @start = Time.now

    @accounts.each_pair do |title, acc_data|
      print "Getting Trending Topics and tweeting to #{title}..." if @verbose

      @twitter = get_twitter_client acc_data

      trends = get_trends acc_data['woeid']
      if trends.length == 10
        puts (!@verbose)? 'OK for '+title : ''
      elsif trends.length != 0
        puts (!@verbose)? "Something is wrong with the trends for #{title}: "+trends.inspect : ''
      elsif trends.length == 0
        puts "Looks like there are no trends. =( Exiting..."
        return false
      end

      make_tweets trends, for_real

      puts '' if @verbose
    end
  end

  private

  # Configures the Twitter Client and returns a new instance of it
  def get_twitter_client acc_data
    Twitter.configure do |c|
      c.consumer_key       = acc_data['consumer_key']
      c.consumer_secret    = acc_data['consumer_secret']
      c.oauth_token        = acc_data['oauth_key']
      c.oauth_token_secret = acc_data['oauth_secret']
    end

    Twitter::Client.new
  end

  # Returns the trends for the location of the woeid given (Where On Earth ID).
  # A list of places and codes can be obtained from Twitter::Client#trend_location
  def get_trends woeid
    trends = ''
    got_error = false
    while trends.empty? and (Time.now - @start) < 60 * 15 do # gives up after 15 minutes
      begin
        print 'Trying to connect again. ' if got_error
        trends = @twitter.local_trends woeid
      rescue OpenSSL::SSL::SSLError, Errno::ECONNRESET => e
        puts (@verbose)? ' Oops! Are you connected ('+e.class.to_s+')? Trying again in 10 seconds.' : e.class.to_s
        got_error = true
        sleep 10
      end
    end

    trends
  end

  # Will tweet the trends given (preferably an Array of 10 elements) if the second argument is true;
  # if it's false, will only pretend to tweet, to show it's working (or not)
  def make_tweets trends, for_real
    now  = Time.now
    time = now.hour.to_s+'h'+('%02d'%now.min)

    tweets = [@format % [time, Twitrends.concat_trends(trends[5..9],5)],
              @format % [time, Twitrends.concat_trends(trends[0..4])]]

    tweets.each do |tweet|
      if for_real
        @twitter.update tweet
        @twitter.update "d igorgsantos Tweet over 140 chars (#{tweet.length})! \"#{tweet[0..80]}\"" if tweet.length > 140
      else
        puts "Tweet (#{tweet.length} chars) >> "+tweet if @verbose
      end
    end
  end

  # Concatenates the topics given, with a number in front of it. The second argument is from where begin counting; if given 5, the first number will be 6.
  def self.concat_trends trends, plus = 0
    trends.collect { |v| i = trends.index(v)+1+plus; "#{i.to_s}. #{v}" } .join(' || ')
  end

end