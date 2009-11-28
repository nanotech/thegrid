#!/usr/bin/env ruby

$LOAD_PATH.push '../lib/'

require 'rubygems'
require 'grid'
include Grid

require 'benchmark'

grid = Stack.new self, Vector(200, 100), Vector(20,20), 60, 6
grid.create :canvas, nil, true
#grid.create :wall
#grid[:wall].walkable = false
#grid[:wall].turn(Vector(9,9), :on)

pathfinder = Pathfinder.new(grid)
target = Vector(199, 99)

path = closed_set = nil

#path, closed_set = pathfinder.astar(Vector(0,0), target)

params = Vector(0,0), target
pf = pathfinder

Benchmark.bmbm do |x|
	x.report('A*') { pf.astar(*params) }
	x.report('Greedy') { pf.greedy(*params) }
	x.report('Dijkstra') { pf.dijkstra(*params) }
end

__END__
grid.create :path

abort "Impossible path" unless path

grid.create :closed
closed_set.each_key do |vect|
	grid[:closed].turn(vect.to_vector, :on)
end

path.each do |vect|
	grid[:path].turn(vect, :on)
end

puts "#{path.size} Steps"
puts grid[:path]
puts "#{closed_set.size} Checked"
puts grid[:closed]
