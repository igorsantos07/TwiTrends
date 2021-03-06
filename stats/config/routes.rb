require 'Charts'

get '/imgs/*' do |img|
	filename = File.join(File.dirname(Sinatra::Application.root),'imgs', img)

	if File.exist? filename
		response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
		response['Content-type'] = 'image/'+File.extname(filename)[1..4]
		File.new filename
	else
		404
	end
end

get '/css/*.css' do | file |
	response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
	less eval(":'css/#{file}'")
end

get %r{/([\w]*)} do |period|
  chart = Charts.new
  @data = (!(period.nil? or period.empty?) and Charts.method_defined?(period.to_sym))?
    eval('chart.'+period) :
    chart.all_time

  haml :index
end