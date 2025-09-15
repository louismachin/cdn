require 'sinatra'
require 'yaml'

require_relative './models/environment'

APP_ROOT = File.expand_path(__dir__)

configure do
    set :bind, '0.0.0.0'
    set :port, $env.port
    set :public_folder, File.expand_path('public', __dir__)
    set :environment, :production
    disable :protection
end

require_relative './helpers/files'

require_relative './routes/session'
require_relative './routes/index'
require_relative './routes/view'
require_relative './routes/upload'
require_relative './routes/download'
require_relative './routes/move'
require_relative './routes/info'
require_relative './routes/list'
require_relative './routes/mimetype'