module ConsoleTweet

  class CLI

    require 'rubygems'
    require 'twitter_oauth'
    require 'yaml'

    # The allowed API methods
    AllowedMethods = [:setup, :help, :status, :tweet, :timeline, :show]

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
      return failtown("Unauthorized, re-run setup!") unless @client && @client.authorized?
      
      # Only send since_id to @client if it's not nil
      home_timeline = since_id ? @client.home_timeline(:since_id => since_id) : @client.home_timeline
      
      if home_timeline.any?
        print_tweets(home_timeline)

        # Save the last id as since_id
        self.since_id = home_timeline.last['id']
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
      return failtown("Unauthorized, re-run setup!") unless @client && @client.authorized?
      # actually post it
      @client.update(tweet_text)
      puts "Tweet Posted!"
    end

    # Get 20 most recent statuses of user, or specified user
    def show(args)
      load_default_token

      target_user=""
      target_user=args[0] unless args.nil?

      res = @client.user_timeline(:screen_name => target_user)

      if res.include? 'error'
        return failtown(" show :: #{res['error']}")
      end
        
      print_tweets(res)
    end

    # Get the user's most recent status
    def status(*args)
      load_default_token
      return failtown("Unauthorized, re-run setup!") unless @client && @client.authorized?
      user = @client.info
      status = user['status']
      puts "#{user['name']} (at #{status['created_at']}) #{status['text']}" unless status.nil?
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
      puts "#{CommandColor}twitter#{DefaultColor} View your timeline, since last view"
      puts "#{CommandColor}twitter setup#{DefaultColor} Setup your account"
      puts "#{CommandColor}twitter status#{DefaultColor} Get your most recent status"
      puts "#{CommandColor}twitter tweet \"Hello World\"#{DefaultColor} Send out a tweet"
      puts "#{CommandColor}twitter show [username]#{DefaultColor} Show a timeline"
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
      if tokens = load_tokens
        default_hash = tokens[:default]
        @client = TwitterOAuth::Client.new(:consumer_key => ConsumerKey, :consumer_secret => ConsumerSecret, :token => default_hash[:token], :secret => default_hash[:secret])
        default_hash
      end
    end

    # Load tokens from the ~/.twitter file
    def load_tokens
      if File.exists?(TOKEN_PATH)
        f = File.open(TOKEN_PATH, 'r')
        tokens = YAML::load(f)
        f.close
        tokens
      end
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
    
    # Getter for since_id in ~/.twitter file
    def since_id
      load_default_token[:since_id]
    end

    # Setter for since_id in ~/.twitter file
    def since_id=(id)
      tokens = load_default_token
      tokens[:since_id] = id
      save_tokens(:default => tokens)
    end

    # Standardized formating of timelines
    def print_tweets(tweets)
      tweets.reverse!
      tweets.each do | tweet|
        puts "#{tweet['text']}\n#{NameColor}@#{tweet['user']['screen_name']} (#{tweet['user']['name']})#{DefaultColor}\n\n"
      end
    end
  end
end
