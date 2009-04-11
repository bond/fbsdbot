# encoding: utf-8

module FBSDBot
  class WhoEvent < Event
    
    attr_reader :to, :channel, :user, :server, :user_server, :message
    
    def initialize(conn, opts = {})
      super(conn)
      params        = opts[:params]
      @server       = opts[:server]
      @to, @channel = params[0..1]
      
      name, host, server, nick, _, @message = params[2..-1]
      @user_server = server
      @user        = User.cache["#{nick}!#{name}@#{host}"]
    end
    
  end
end
