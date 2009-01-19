#!/usr/bin/env ruby

#
# = Automatic Updater
#
# Updates an application using Git.
#
# Pass a Ruby script as an argument on the command line
# to run it after the updater finishes.
#

require 'rubygems'
require 'gosu'
include Gosu

require 'open3'
require 'lib/timer'

extra_paths = ['/opt/local/bin']
extra_paths.each do |path|
	if File.exists?(path) and !ENV['PATH'].include?(path)
		ENV['PATH'] += (':' + path)
	end
end

class Updater < Window
	WIDTH  = 400
	HEIGHT = 100

	def initialize
		super(WIDTH, HEIGHT, false)
		self.caption = 'Updater'
		@font = Font.new(self, default_font_name, 30)
		@message = "Updating..."

		Thread.abort_on_exception = true
		
		@thread = Thread.new do
			execute('git checkout master')
			@message = execute('git pull origin master', :stdout).last
		end
	end

	def execute(command, output=nil)
		Open3.popen3(command) do |i,o,e|
			std = {
				:stdout => o, 
				:stderr => e
			}

			std[output].readlines if std[output]
		end
	end

	def update
		if !@timer and @thread.status == false
			@timer = Timer.new(1500) do
				IO.popen("ruby #{ARGV[0]}") if ARGV[0]
				exit
			end
		end

		@timer.update if @timer
	end

	def draw
		@font.draw_rel(@message, WIDTH / 2, HEIGHT / 2,
					   0, 0.5, 0.5)
	end
end

Updater.new.show
