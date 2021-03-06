set({
	:port   => 4500,
	:logging => false,
  :db => File.join(File.dirname(settings.root), 'stats/stats.db')
})

configure do |app|
	app.also_reload 'config/*.rb', '*.rb'
end if development?