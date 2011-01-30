require 'sqlite3'

DAY = 60*60*24
WEEK = DAY * 7
MONTH = DAY * 30
YEAR = MONTH * 12

TODAY = Time.mktime(Time.new.year, Time.new.month, Time.new.day).to_i

class Charts
  def initialize
    @db = SQLite3::Database.new settings.db

    @data = {}
    @db.execute('SELECT name FROM accounts') { |acc| @data[acc[0]] = Array.new }

    @today = Time.mktime(Time.new.year, Time.new.month, Time.new.day).to_i
    @default_query = 'SELECT name, date, followers FROM stats s JOIN accounts a ON (s.account = a.id)'
  end

  def weekly
    make_query @default_query+" WHERE date => #{Time.at(TODAY - WEEK)} AND date <= #{TODAY}"
    generate_img_url
  end

  def monthly
    make_query @default_query+" WHERE date => #{Time.at(TODAY - MONTH)} AND date <= #{TODAY}"
    generate_img_url
  end

  def yearly
    make_query @default_query+" WHERE date => #{Time.at(TODAY - YEAR)} AND date <= #{TODAY}"
    generate_img_url
  end

  def all_time
    make_query @default_query
    generate_img_url
  end

  #############
    private
  #############

  def make_query query
    @db.execute(query) do |values|
      @data[values[0]] << {
        :date => Time.at(values[1].to_i).strftime('%Y-%m-%d %Hh'),
        :followers => values[2]
      }
    end

		generate_img_url
  end

	def generate_img_url
    #TODO can i join those two lines in only one?
    chart_data_arr = []
    chart_labels = []

    #populating data array
    i = 0
    chart_data_arr = @data.values.collect do |acc_data|
      followers = []
      followers = acc_data.collect do |dataset|
        chart_labels << dataset[:date] if i == 0
        dataset[:followers]
      end
      i += 1

      followers
    end

    #finding min and max for chart size and joining data
    #TODO can i join those two lines in only one?
    min = []
    max = []
    chart_data = chart_data_arr.collect! do |data|
      min << data.min.to_i
      max << data.max.to_i
      data.join(',')
    end.join '|'

    min = min.min
    max = max.max
    chart_data_size = @data.length.times.collect do
      (min.to_i-50).to_s+','+
      (max.to_i+50).to_s
    end.join ','

		{ :img =>
      'http://chart.googleapis.com/chart?cht=lc'+
      '&chdl='+@data.keys.join('|')+ #names
      '&chds='+chart_data_size+ # min,max for each datagroup
      '&chd=t:'+chart_data+  #data

      '&chxt=x,x,y,y'+ #what axis to show
      '&chxp=1,50|3,50'+ #axis position
      '&chxl='+ #axis values
        '0:|'+chart_labels.join('|')+'|'+
        '1:|Dates|'+
        '2:|'+min.to_s+'|'+(max-min/2).to_s+'|'+max.to_s+'|'+
        '3:|Followers'+

      '&chs=800x350'+ #dimensions
      '&chma=10,10,10,10'+ #margin

      '&chco=FF0000,0000FF,888888'+ #line colors
      '&chf=bg,s,B2DFDA00|c,s,D6EEEB'+ #last 2 zeroes for bg makes it fully transparent

      '&chg=50,20'+
      '&chls=3|3|3'+ #line style (tickness, dash length, space length)
      '&chm=o,FF0000,0,1,6|o,0000FF,1,1,6|o,888888,2,1,6' #bullets (type, color, datagroup, which points, size)
    }
	end
end