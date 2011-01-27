set({
	:port   => 4500,
	:logging => false,
})

configure do |app|
	app.also_reload 'config/*.rb', '*.rb'
end