begin
	require 'rubygems'
rescue LoadError
end

require 'helpers'
require 'vector'
require 'gooey'
require 'forwardable'

#
# Provides some common game-related features such as
# camera position and scene switching.
#
class Screens < Gooey::Window
	attr_reader :width, :height, :center, :fullscreen
	attr_accessor :camera

	def initialize(caption='', width=1280, ratio=Rational(16,10), fullscreen=false)
		@width = width
		@height = (width / ratio).numerator
		@center = [@width / 2, @height / 2]
		@fullscreen = (fullscreen != false)

		super(@width, @height, @fullscreen)
		$window = self

		self.caption = caption

		# Scrolling is stored as the position of the top left corner of the screen.
		@camera = Vector(0,0)

		@screens = {}
		@current_screen = nil
	end

	def switch_to(screen, *args, &block)
		screen = screen.to_s

		required = require 'screens/' + screen.underscore

		if n = args.index(:cleanup)
			args.delete(n)
			run_after = Proc.new do
				destroy! @current_screen.name
			end
		end

		unless @screens[screen]
			klass = screen.constantize
			@screens[screen] = klass.new(self, screen, *args)
		end

		# Callbacks

		yield @current_screen, @screens[screen] if block
		run_after.call if run_after

		if @current_screen.respond_to?(:leave)
			@current_screen.send(:leave) 
		end

		if @screens[screen].respond_to?(:enter)
			@screens[screen].send(:enter) 
		end

		remove_subview @current_screen if @current_screen
		@current_screen = @screens[screen]
		add_subview @current_screen
	end

	def destroy!(screen)
		@screens.delete(screen)
	end

	def update; @current_screen.update end

	# Default key mappings
	def button_down(id)
		@current_screen.button_down(id)
	end
end

class Screen < Gooey::View
	attr_accessor :window, :name

	include Gosu

	def initialize(window, name, *ignored)
		super(window.frame)
		@window = window
		@name = name
		@height = window.height
		@width = window.width

		extend SingleForwardable
		def_delegators :@window, *(@window.methods - self.methods)
	end

	def update; end

	def button_down(id)
		if id == KbEscape then @window.close end
	end

	def destroy!
		@window.destroy! @name	
	end
end
