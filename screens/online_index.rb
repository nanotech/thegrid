require 'net/http'
require 'uri'
require 'yaml'
require 'text_field'

#
# The online game list.
#
class OnlineIndex < Screen
	attr_reader :grid

	include Grid
	require 'grid/menu'

	SERVER = 'http://localhost/~NanoTech/thegrid-server/public/'

	def initialize(*args)
		super

		@title = Font.new(@window, Gosu::default_font_name, 80)
		@status_font = Font.new(@window, Gosu::default_font_name, 30)
		@font = Font.new(@window, Gosu::default_font_name, 24)
		@menu = Menu.new(self, @font, :vertical,
						 Vector(3, 12), Vector(20,120),
						 Vector(400, 40), Vector(10, 10))

		@postdata = {}

		@input_field = TextField.new(
			@window, [25,@window.height-65], @window.width - 50,
			'Enter your username', Gosu::default_font_name, 40
		)

		@input_field.padding = 15
		@text_stack = []
	end

	def button_down(id)
		@input_field.button_down(id) do |saved|
			if saved
				if @text_stack.size < 2
					@text_stack << @input_field.text
					@input_field.clear
					@input_field.select
					@status = '...and now your password'
				end

				if @text_stack.size == 2
					@status = ''
					login *@text_stack
					@text_stack.clear
					@input_field.deselect
				end
			end
		end
		@menu.click if id == MsLeft
		@window.switch_to :main_menu if id == KbBackspace
	end

	def login(username, password)
		credentials = {
			'username' => username,
			'password' => password
		}

		data = get 'login', credentials
		fetch if data
	end

	def fetch
		resp = get 'games', @postdata

		if resp[:error]
			@status = resp[:error].to_s
		else
			@games = resp['data']['games']

			@games.each do |game|
				@menu.add game['name'] => [:get, "games/#{game['id']}", @postdata]
			end
		end
	end

	def get(url, data={})
		path = URI.parse(SERVER + url)
		resp, data = Net::HTTP.post_form(path, data)

		yaml = YAML::load(data)

		if yaml.is_a?(Hash) and yaml['session_id']
			@postdata['session_id'] = yaml['session_id']
			yaml
		else
			@status = yaml.to_s
			return nil
		end
	end

	def draw
		@window.draw_quad(
			0,      @height - 500, 0xff000000, # top left
			@width, @height - 500, 0xff000000, # top right
			0,      @height,       0xff222222, # bottom left
			@width, @height,       0xff222222  # bottom right 
		)

		@title.draw('Play Online', 40, 20, 0)

		@window.draw_line(mouse_x, mouse_y, 0xffffffff,
						  mouse_x + 20, mouse_y + 20, 0xffffffff,
						  ZOrder::UI + 10)

		@menu.draw
		@input_field.draw
		@status_font.draw(@status, 40, @window.height - 140, 10)
	end
end
