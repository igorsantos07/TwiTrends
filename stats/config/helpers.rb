helpers do
  def css file
    "/css/#{file}.css?" + File.mtime(File.join(settings.views, "css", "#{file}.less")).to_i.to_s
  end

  def js file
    "/js/#{file}.js?" + File.mtime(File.join(settings.views, "js", "#{file}.js")).to_i.to_s
  end

	def graph

	end
end