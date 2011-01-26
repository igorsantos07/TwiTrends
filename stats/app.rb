require 'sinatra'
require 'sinatra/reloader' if development?
require 'less'

require 'config/config'
require 'config/helpers'
require 'config/routes'