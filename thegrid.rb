#!/usr/bin/env ruby

#
# Run this file to start the game.
#

DEVEL = true

$LOAD_PATH.push 'lib/'
require 'screens'
require 'player'

# Layering of sprites
module ZOrder
	Background, Tiles, Blocks, UI = 0, 100, 1_000, 10_000
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
		switch_to :login_screen
	end

	def login_as username, password=false
		@player = Player.login username, password
	end
end

Game.new.show
