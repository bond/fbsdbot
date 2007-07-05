module FBSDBot
	class Authentication
		def initialize
			@authenticated = {}
		end
		
		def authenticate(action,handle,password)
			u = User.find(:first, :include => [:hosts], :conditions => ['handle = ?',handle])
			puts u.inspect
			return false if u.nil?
			
			#got user, now check pw
			return false unless u.check_password(password)
			
			# XXX: TODO, fix matching of hostmask against user, not just pass			
			@authenticated[action.nick.to_sym] = AuthenticatedUser.new(a,u)
			true
		end
		
		def is_authenticated?(action)
			a = @authenticated[action.nick.to_sym]
			if a.nil?
				return false
			elsif a.host_changed?(action.hostmask)
				@authenticated.delete(action.nick.to_sym)
				return false
			end
			true
		end

		def logout(action)
			a = @authenticated[action.nick.to_sym]
			@authenticated.delete(action.nick.to_sym) unless a.nil?
			true
		end

		def mapuser(action)
			@authenticated[action.nick.to_sym]
		end
		
	end
	
	private
	class AuthenticatedUser
		attr_reader :login_date, :event, :idle_since, :user

		def initialize(action,u)
			@event = action
			@user = u
			@login_date = Time.now
		end

		def host_changed?(host)
			host == @action.hostmask ? false : true
		end
		
	end
end