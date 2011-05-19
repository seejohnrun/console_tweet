module ConsoleTweet

  class CLI

    require 'rubygems'
    require 'twitter_oauth'
    require 'yaml'

    # The allowed API methods
    AllowedMethods = [:setup, :help, :status, :tweet, :timeline]

    # Twitter API details
    ConsumerKey = 'MvVdCyl6xCVtEUVdcp4rw'
    ConsumerSecret = '3xD0oy47WhWYUIBCU6QzcIBqsrAAL3KnYWKhd6ALk2k'

    # Where to store the .twitter file
    TOKEN_PATH = File.expand_path('~/.twitter')

    # Some colors used in the output
    NameColor = "\e[33m"
    CommandColor = "\e[36m"
    DefaultColor = "\e[0m"
    ErrorColor = "\e[31m"

    # By default there are no arguments and no commands
    def initialize
      @commands = []
      @arguments = {}
    end

    # Get the commands from the command line
    # (Somewhat primitive, will be expanded) TODO
    def start
      ARGV.each do |arg|
        unless arg.index('-') === 0 
          @commands << arg
        end
      end
      # get the first command as the method, and the rest of the commands as args
      method = @commands.empty? ? :timeline : @commands[0].to_sym
      return method_missing(method) unless AllowedMethods.include?(method)
      self.send(method, @commands[1..@commands.size])
    end
  
    # Prompt the user for a PIN using a request token, and see if we can successfully authenticate them
    def get_access_token
      @client = TwitterOAuth::Client.new(:consumer_key => ConsumerKey, :consumer_secret => ConsumerSecret)
      request_token = @client.request_token
      # ask the user to visit the auth url
      puts "To authenticate your client, visit the URL: #{request_token.authorize_url}"
      # wait for the user to give us the PIN back
      print 'Enter PIN: '
      begin
        @client.authorize(request_token.token, request_token.secret, :oauth_verifier => self.class.get_input.chomp)
      rescue OAuth::Unauthorized
        false # Didn't get an access token
      end
    end
    
    # Display the user's timeline
    def timeline(*args)
      load_default_token
      return failtown("Unauthorized, re-run setup!") unless @client.authorized?
      friends_timeline = @client.friends_timeline
      friends_timeline.reverse! # We want the latest tweets at the bottom on a CLI
      friends_timeline.each do |tweet|
        puts "#{tweet['text']}\n\t#{NameColor}#{tweet['user']['name']}#{DefaultColor}\n\n"
      end
    end
    
    # Send a tweet for the user
    def tweet(*args)
      load_default_token
      # get it from them directly
      tweet_text = args.join(' ').strip
      # or let them append / or pipe
      tweet_text += (tweet_text.empty? ? '' : ' ') + STDIN.read unless STDIN.tty?
      # or let them get prompted for it
      if tweet_text.empty?
        print 'Tweet (Press return to finish): '
        tweet_text = STDIN.gets.strip
      end
      return failtown("Empty Tweet") if tweet_text.empty?
      return failtown("Tweet is too long!") if tweet_text.size > 140
      return failtown("Unauthorized, re-run setup!") unless @client.authorized?
      # actually post it
      @client.update(tweet_text)
      puts "Tweet Posted!"
    end

    # Get the user's most recent status
    def status(*args)
      load_default_token
      return failtown("Unauthorized, re-run setup!") unless @client.authorized?
      user = @client.info
      status = user['status']
      puts "#{user['name']} (at #{status['created_at']}) #{status['text']}"
    end

    # Get the access token for the user and save it
    def setup(*args)
      # Keep trying to get the access token
      until @access_token = self.get_access_token
        print "Try again? [Y/n] "
        return false if self.class.get_input.downcase == 'n'
      end
      # When we finally get it, record it in a dotfile
      tokens = {:default => { :token => @access_token.token, :secret => @access_token.secret }}
      save_tokens(tokens)
    end

    # Display help section
    def help(*args)
      puts "#{NameColor}console-tweet#{DefaultColor} by John Crepezzi <john.crepezzi@gmail.com>"
      puts 'http://github.com/seejohnrun/console-tweet'
      puts
      puts "#{CommandColor}twitter setup#{DefaultColor} Setup your account"
      puts "#{CommandColor}twitter status#{DefaultColor} Get your most recent status"
      puts "#{CommandColor}twitter tweet \"Hello World\"#{DefaultColor} Send out a tweet"
    end

    # Show error message with help below it
    def failtown(message = nil)
      puts "#{ErrorColor}Uh-oh! #{message}#{DefaultColor}\n" if message
      help
    end

    # Catch other methods
    def method_missing(command, *arguments)
      failtown "Unknown command: #{command}\n"
    end

    private

    # Load the default token from the ~/.twitter file
    def load_default_token
      tokens = load_tokens
      default_hash = tokens[:default]
      @client = TwitterOAuth::Client.new(:consumer_key => ConsumerKey, :consumer_secret => ConsumerSecret, :token => default_hash[:token], :secret => default_hash[:secret])
    end

    # Load tokens from the ~/.twitter file
    def load_tokens
      f = File.open(TOKEN_PATH, 'r')
      tokens = YAML::load(f)
      f.close
      tokens
    end

    # Save the set of tokens to the ~/.twitter file
    def save_tokens(tokens)
      f = File.open(TOKEN_PATH, 'w')
      YAML::dump(tokens, f)
      f.close
    end

    # Get input from STDIN, strip it and cut the newline off the end
    def self.get_input
      STDIN.gets.strip.chomp
    end

  end

end
