ENV_FILE_PATH = 'environment.yml'

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
        puts attempt.inspect
        return attempt[:password] == @data.dig('password')
    end
end

$env = Environment.new