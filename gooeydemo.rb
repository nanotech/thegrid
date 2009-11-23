#!/usr/bin/env ruby -rubygems

DEVEL = true
$LOAD_PATH.push 'lib/'
require 'gosu'
require 'gooey'

class SquareView < Gooey::View
	def draw
		line x,       y,        width+x,  y,        0xffffffff, 0xffffffff
		line x,       y,        x,        height+y, 0xffffffff, 0xffffffff
		line width+x, y,        width+x,  height+y, 0xffffffff, 0xffffffff
		line x,       height+y, width+x,  height+y, 0xffffffff, 0xffffffff
	end
end

class GooeyDemo < Gooey::Window
	include Gooey

	def initialize
		super(800, 600, false)
		$window = self
		@square = SquareView.new(Rect.new(Point.new(10,10), Size.new(100,100)))
		add_subview @square
		inner_square = SquareView.new(Rect.new(Point.new(10,10), Size.new(80,80)))
		@square.add_subview inner_square
	end

	def update
		@square.x = Math::sin(Gosu::milliseconds * 0.001) * 200 + 210
	end
end

GooeyDemo.new.show
