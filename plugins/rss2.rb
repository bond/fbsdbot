# encoding: utf-8

# =====================
# = RSS Reader Plugin =
# =====================

require 'uri'
require 'cgi'
require 'rss/1.0'
require 'rss/2.0'


include FBSDBot::IRC::Commands

FBSDBot::Plugin.define "rss" do
  author "Daniel Bond"
  version "0.0.1"
  commands %w{rss}

  @rssfeeds = {
    :src => 'http://gitweb.dragonflybsd.org/dragonfly.git/rss'
  }
  @maxitems = 5
  @lastitem = {}
  @started = false
  
  EventMachine::PeriodicTimer.new(30) do
    if @started
      @rssfeeds.each do |name,uri|

        uri = URI.parse(uri)
        next unless ['http'].include?( uri.scheme )

        client = EM::Protocols::HttpClient2.connect( uri.host, 80 )
        request = client.get( uri.query ? "#{uri.path}?#{uri.query}" : uri.path )

        request.callback {|response|
          if(response.status == 200)
            items = Array.new
            rss = RSS::Parser.parse(response.content)

            # check if we have valid RSS
            next if rss.nil?
            rss.items.each do |item|

              # We haven't got a lastitem, use first item and break
              if @lastitem[name].nil?
                items << item
                break
              else
                # if new items since lastitem, print up to 5 of them
                break if (@lastitem[name] == item.guid.content || items.length == @maxitems)
                items << item
              end
            end

          @lastitem[name] = items.first.guid.content if(items.length > 0)
          items.each do |item|
            Log.info "RSS2 plugin: Got #{items.length} items"
            if not Manager.workers[:EFnet].nil? and Manager.workers[:EFnet].connected?
              tinycl = EM::Protocols::HttpClient2.connect( 'tinyurl.com', 80 )
              tinyreq = tinycl.get( "/api-create.php?url=#{CGI.escape(item.link)}")
              tinyreq.callback{|res|
                if(res.status == 200)
                  Manager.workers[:EFnet].send_privmsg("#{name}: '#{item.description}' by #{item.author} <#{res.content}>", '#dragonflybsd')
                else
                  Log.warn "RSS2: tinyurl.com returned #{res.status}"
                  Manager.workers[:EFnet].send_privmsg("#{name}: '#{item.description}' by #{item.author} <#{item.link}>", '#dragonflybsd')
                end
              }

            end
          end
          end
        }
      end
    end

  end

  def on_join(action)
    return if @started
    @started = true
  end
end