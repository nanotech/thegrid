require 'net/http'
require 'timer'

#
# The online update interface.
#
class CheckForUpdates < Screen
	def initialize(*args)
		super

		@font = Font.new(@window, Gosu::default_font_name, 30)
	end

	def enter
		@hash = `git log --pretty=oneline --no-color -n1`
		@hash = @hash.match(/[a-f0-9]{40}/)[0]

		@status_message = 'Checking...'
		check
	end

	def draw
		@font.draw_rel(@status_message, @window.width / 2, @window.height / 2,
					   0, 0.5, 0.5)
	end

	def update
		@timer.update if @timer
	end

	def check
		Thread.abort_on_exception = true
		
		@check_thread = Thread.new do
			feed = fetch("http://github.com/feeds/#{Game::MAINTAINER}/commits/#{Game::NAME}/master")
			@new_hash = feed.body.match(/commit\/([a-f0-9]{40})/)[1]

			@status = (@hash == @new_hash)

			if @status
				@status_message = "You have the latest version."

				@timer = Timer.new(1500) do
					@window.switch_to :main_menu
				end
			else
				@status_message = "There's an update available."

				require 'tempfile'

				tmp = Tempfile.new('updater')
				File.open('updater.rb').each do |line|
					tmp.write(line)
				end

				tmp.flush

				updater = IO.popen("ruby '#{tmp.path}' #{$0}")

				@timer = Timer.new(500) { exit }
			end
		end
	end

	def fetch(uri_str, limit = 10)
		# You should choose a better exception.
		raise ArgumentError, 'HTTP redirect too deep' if limit == 0

		response = Net::HTTP.get_response(URI.parse(uri_str))
		case response
		when Net::HTTPSuccess     then response
		when Net::HTTPRedirection then fetch(response['location'], limit - 1)
		else
			response.error!
		end
	end
end
