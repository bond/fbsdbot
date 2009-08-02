# encoding: utf-8
module FBSDBot
  class NoSuchNickChannelEvent < Event

    attr_reader :to, :target, :message, :server

    def initialize(conn, opts = {})
      super(conn)
      @to, @target, @message = opts[:params]
      @server = opts[:server]
    end

  end
end
