#!/usr/bin/env ruby

#
# Run this file to start the game.
#

DEVEL = true

$LOAD_PATH.push 'lib/'
require 'screens'
require 'gooey'
require 'player'

# Layering of sprites
module ZOrder
	Background, Tiles, Blocks, UI = 0, 100, 1_000, 10_000
	Cursor = UI + 10
end

class Cursor < Gooey::View
	Width = 20

	def initialize
		super(Rect.new(Point::Zero, Size.new(Width, Width)))
	end

	def draw
		line(mouse.x, mouse.y, mouse.x + Width, mouse.y + Width,
			 0xffffffff, 0xffffffff, ZOrder::Cursor)
	end
end

#
# The main, top-level game class.
#
class Game < Screens
	NAME = 'thegrid'
	MAINTAINER = 'nanotech'

	attr_reader :player

	def initialize
		super 'The Grid'
		self.cursor_view = Cursor.new
		switch_to DEVEL ? :game_grid : :login_screen
	end

	def login_as username, password=false
		@player = Player.login username, password
	end
end

Game.new.show
