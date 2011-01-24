require 'rubygems'
require 'twitter'

list = 'http://tinyurl.com/TwiTrends'

yaml_file = (File.exists? 'accounts.yaml')? 'accounts.yaml' : $LOAD_PATH[0]+'/accounts.yaml'
accounts = YAML::load_file yaml_file

account_names = accounts.keys << 'igorgsantos'

accounts.each_pair do |account,data|
	puts "Updating information for @#{account}: "

  Twitter.configure do |c|
    c.consumer_key       = data['consumer_key']
    c.consumer_secret    = data['consumer_secret']
    c.oauth_token        = data['oauth_key']
    c.oauth_token_secret = data['oauth_secret']
  end
	twitter = Twitter::Client.new

	twitter.update_profile({
		:name					=> data['account']['name'],
		:location			=> data['account']['location'],
		:description	=> data['account']['description']+' Admin: @IgorGSantos. '+data['account']['bros']+': '+list
	})
	puts '	Profile, done!'

	twitter.update_profile_image File.new(File.join('imgs',data['account']['image']))
	puts '	Image, done!'

	twitter.update_profile_background_image File.new(File.join('imgs','bg.gif'))
	twitter.update_profile_colors({
		:profile_background_color			=> 'B2DFDA',
		:profile_text_color						=> '333333',
		:profile_link_color						=> '92A644',
		:profile_sidebar_fill_color		=> 'FFFFFF',
		:profile_sidebar_border_color	=> 'EEEEEE'
	})
	puts '	Layout, done!'

	new_follows = 0
	account_names.each do |acc|
		begin
			twitter.follow acc
			new_follows += 1
		end	unless twitter.friendship_exists? account, acc or acc == account
	end
	puts "	Followers, done! #{new_follows} new"

	puts '	Everything is OK!'
end