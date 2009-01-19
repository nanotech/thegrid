#!/usr/bin/env ruby

#
# Run this file to start the game.
#

$LOAD_PATH.push 'lib/'
require 'screens'

# Layering of sprites
module ZOrder
	Background, Tiles, Blocks, UI = *0..5
end

#
# The main, top-level game class.
#
class Game < Screens
	NAME = 'thegrid'
	MAINTAINER = 'nanotech'

	def initialize
		super('The Grid')
		switch_to 'main_menu'
	end
end

Game.new.show
