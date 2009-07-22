#!/usr/bin/env ruby

$: << 'lib'
require 'player'

describe Player do
	it "should have the username given to it" do
		player = Player.new "Joe"
		player.username.should == "Joe"
	end

	it "should load existing players when logging in,
		but create new ones if they don't exist" do

		Player.players[:Joe].should == nil
		joe = Player.login "Joe"
		Player.players[:Joe].should == joe
	end
end
