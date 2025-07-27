require 'sinatra'

require_relative './models/environment'

APP_ROOT = File.expand_path(__dir__)

set :bind, '0.0.0.0'
set :port, $env.port
set :public_folder, File.expand_path('public', __dir__)

require_relative './helpers/files'

require_relative './routes/session'
require_relative './routes/index'
require_relative './routes/upload'
require_relative './routes/download'