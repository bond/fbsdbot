# encoding: utf-8
module FBSDBot
  class EndOfWhoEvent < Event

    attr_reader :to, :target, :message
    
    def initialize(conn, opts = {})
      super(conn)
      @to, @target, @message = opts[:params]
      @server = opts[:server]
    end
    
  end
end

# :params=>["to", "target", "End of /WHO list."]