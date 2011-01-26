require 'Charts'

get %r{/([\w]*)} do |period|
  @data = !period.nil? && Charts.method_defined?(('Charts.'+period).to_sym)?
    eval('Charts.'+period) :
    Charts.all_time

  haml :index
end