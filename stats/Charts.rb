class Charts
  def Charts.monthly
    'monthly'
  end

  def Charts.weekly
    'weekly'
  end

  def Charts.yearly
    'yearly'
  end

  def Charts.all_time
		@data= { :img => self.generate_img_url(data) }
  end

	## private ##
	def Charts.generate_img_url data
		'http://chart.googleapis.com/chart?cht=lc'+
		'&chdl=TrendingUSA|TrendsSP|TrendsRJ'+ #names
		'&chds=0,150,0,150,0,150'+ # min,max for each datagroup
		'&chd=t:'+  #data
			'10,25,135|'+
			'5,7,9|'+
			'0,0,10'+

		'&chxt=x,x,y,y'+ #what axis to show
		'&chxp=1,50|3,50'+ #axis position
		'&chxl='+ #axis values
			'0:|14/10|19/10|24/10|'+
			'1:|Dates|'+
			'2:|0|30|60|90|120|150|'+
			'3:|Followers'+

		'&chs=800x350'+ #dimensions
		'&chma=10,10,10,10'+ #margin

		'&chco=FF0000,0000FF,888888'+ #line colors
		'&chf=bg,s,B2DFDA00|c,s,D6EEEB'+ #last 2 zeroes for bg makes it fully transparent

		'&chg=50,20'+
		'&chls=3|3|3'+ #line style (tickness, dash length, space length)
		'&chm=o,FF0000,0,1,6|o,0000FF,1,1,6|o,888888,2,1,6' #bullets (type, color, datagroup, which points, size)
	end
end