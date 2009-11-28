#!/usr/bin/env ruby

$LOAD_PATH.push '../lib/'

require 'rubygems'
require 'grid'
include Grid

require 'benchmark'

size = Vector(200, 100)
start = Vector(0, 0)
finish = Vector(199, 99)
params = [Vector(0,0), finish]

grid = Stack.new self, size, Vector(20,20), 60, 6
grid.create :canvas, nil, true
pf = Pathfinder.new(grid)

puts "Calculate path from #{start} to #{finish}\n" +
	 "on a #{size} grid with no obstacles.\n\n"

Benchmark.bmbm do |x|
	x.report('A*') { pf.astar(*params) }
	x.report('Greedy') { pf.greedy(*params) }
	x.report('Dijkstra') { pf.dijkstra(*params) }
end
