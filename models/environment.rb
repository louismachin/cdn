ENV_FILE_PATH = 'environment.yml'

Cache = Struct.new(:cached_at, :data, :expiry) do
    def expired?
        Time.now - cached_at > expiry
    end
end

class Environment
    attr_reader :data
    attr_accessor :given_tokens

    def initialize
        if File.file?(ENV_FILE_PATH)
            require 'yaml'
            @data = YAML.load_file(ENV_FILE_PATH)
            @given_tokens = []
        else
            puts "ERROR: 'environment.yml' file is missing..."
            exit
        end
    end

    def port
        @data.dig('port')
    end

    def cookie_name
        @data.dig('cookie_name')
    end
    
    def default_copy
        { title: "CDN" }
    end

    def new_token
        token = Array.new(12) { [*'0'..'9', *'a'..'z', *'A'..'Z'].sample }.join
        @given_tokens << token
        return token
    end
    
    def check_attempt(attempt)
        username, password = attempt[:username], attempt[:password]
        user = @data.dig('users', username)
        return user && (user['password'] == password)
    end

    def check_cookie(cookie)
        self.given_tokens.include?(cookie)
    end

    def check_api_key(api_key)
        all_api_keys = @data.dig('users').map { |_, data| data.dig('api_keys') }.flatten
        return all_api_keys.include?(api_key)
    end
end

$env = Environment.new