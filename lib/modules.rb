module IRCHelpers
	class NickObfusicator
		def NickObfusicator.run( old_nick )
			# find stuff to replace
			new_nick = old_nick
			nick_map = { "a" => "4", "l" => "1", "o" => "0", "e" => "3" } 

			candidates = old_nick.scan(/([aloe])/)
			other_options = ["-","_"]

			i_replacements = 0

			if candidates.size > 0
				candidates = candidates.uniq 
				candidates.each {|c| new_nick = new_nick.to_s.sub("a", nick_map["a"]); i_replacements += 1 }
			end
		
			if i_replacements == 0
				new_nick += other_options[rand((other_options.size) -1)]
				i_replacements += 1
			end
			new_nick
		end
	end
end

class FBSDBot
	def initialize(bot_obj)
		@bot = bot_obj
	end
	def handle_privmsg(event)
		@bot.send_message("#bot-test.no", event.inspect)	
	end
end

# namespace for plugins
module Plugins
end

def load_plugin(name, bot)
   begin
      n = name.downcase
      Plugins.module_eval { load("../plugins/#{n}.rb") }

      if (klass = self.class.const_get(n.capitalize))
         plugin = klass.instantiate(bot)
         puts "Plugin '#{plugin.name.capitalize}' loaded."
      else
         puts "Error loading plugin '#{n.capitalize}':"
         puts "Couldn't locate plugin class. \n Check casing of file and class names (no TitleCase or camelCase allowed)."
      end
   rescue Exception => e
      puts "Error loading core plugin '#{n.capitalize}':"
      puts e.message
      puts e.backtrace.join("\n")
   end

end