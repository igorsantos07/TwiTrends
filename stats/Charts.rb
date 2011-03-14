require 'sqlite3'

$day = 60*60*24
$week = $day * 7
$month = $day * 30
$year = $month * 12

$today = Time.mktime(Time.new.year, Time.new.month, Time.new.day).to_i

class Charts
  def initialize
    @db = SQLite3::Database.new settings.db

    @data = {}
    @db.execute('SELECT name, color, tweets FROM accounts') do |acc|
			@data[acc[0]] = {
				:color => acc[1],
        :tweets => acc[2],
				:stats => [],
        :last_followers => 0
			}
		end

    @today = Time.mktime(Time.new.year, Time.new.month, Time.new.day).to_i
    @default_query = 'SELECT name, date, followers FROM stats s JOIN accounts a ON (s.account = a.id)'
  end

  def weekly
    make_query @default_query+" WHERE date >= #{Time.at($today - $week).to_i} AND date <= #{$today}"
    generate_img_url
  end

	def biweekly
    make_query @default_query+" WHERE date >= #{Time.at($today - $week*2).to_i} AND date <= #{$today}"
    generate_img_url
	end

  def monthly
    make_query @default_query+" WHERE date >= #{Time.at($today - $month).to_i} AND date <= #{$today}"
    generate_img_url
  end

  def yearly
    make_query @default_query+" WHERE date >= #{Time.at($today - $year).to_i} AND date <= #{$today}"
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
		last_date = ''
    @db.execute(query) do |values|
      values[2] = values[2].to_i

			date = Time.at(values[1].to_i).strftime('%m-%d')
      @data[values[0]][:stats] << {
        :date => date,
        :followers => values[2]
      } unless @data[values[0]][:stats].any? { |data| data[:date] == last_date } # won't repeat dates
			last_date = date

			@data[values[0]][:last_followers] = values[2] if @data[values[0]][:last_followers] < values[2]
    end

		totals = {}
		@data.each_pair { |acc, data| totals[acc] = data[:stats].length }
		max_total = totals.values.max
		totals.each_pair do |acc, total|
			if (total < max_total)
				@data[acc][:stats].unshift(Array.new(max_total - total, 0)).flatten!
			end
		end

		generate_img_url
  end

	def generate_img_url
    #TODO can i join those two lines in only one?
    chart_data_arr = []
    chart_labels = []

    #populating data array
    i = 0
		line_colors = []
    chart_data_arr = @data.values.collect do |acc_data|
			l = 0
			line_colors << acc_data[:color]
      followers = []
      followers = acc_data[:stats].collect do |dataset|
				chart_labels[l] = if l % 2 == 0 then dataset[:date] else ' ' end
				l += 1

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
    end

    min = min.min
    max = max.max
		chart_lines_style = []
    chart_data_size = @data.length.times.collect do
			chart_lines_style << 2 # tickness
      min.to_s+','+max.to_s
    end

		chart_legends = @data.collect { |acc, data| "#{acc} (#{data[:last_followers]})" }

		c = -1
		{
      :data => @data,
      :img => 'http://chart.googleapis.com/chart?cht=lc'+
      '&chdl='+chart_legends.join('|')+ #names
      '&chds='+chart_data_size.join(',')+ # min,max for each datagroup
      '&chd=t:'+chart_data.join('|')+  #data

      '&chxt=x,x,y,y'+ #what axis to show
      '&chxp=1,50|3,50'+ #axis position
      '&chxl='+ #axis values
        '0:|'+chart_labels.join('|')+'|'+
        '1:|Dates|'+
        '2:|'+min.to_s+'|'+((max-min)/4).to_s+'|'+((max-min)*2/4).to_s+'|'+((max-min)*3/4).to_s+'|'+max.to_s+'|'+
        '3:|Followers'+

      '&chs=800x350'+ #dimensions
      '&chma=10,10,10,10'+ #margin

      '&chco='+line_colors.join(',')+ #line colors
      '&chf=bg,s,B2DFDA00|c,s,D6EEEB'+ #last 2 zeroes for bg makes it fully transparent

      '&chg='+(100.0/(chart_labels.length-1)).to_s+','+(100/4).to_s+
			'&chls='+chart_lines_style.join('|')+ #line style (tickness, dash length, space length)
      '&chm='+(line_colors.collect {|color| "o,#{color},#{c+=1},,5"} ).join('|') #bullets (type, color, datagroup, which points, size)
    }
	end
end