#!/usr/bin/env ruby

$LOAD_PATH.push '../lib/'

require 'benchmark'
require 'vector'

vector1 = Vector.new(5, 10)
vector2 = Vector.new(8, 39)

n = 300_000

Benchmark.bm(20) do |x|
	x.report('Vector.new:') { n.times { Vector.new(8,40) } }
	x.report('Vector#to_i:') { n.times { vector1.to_i } }
	x.report('Numeric#to_vector:') { n.times { 5.to_vector } }
	x.report('Vector + Numeric:') { n.times { vector1 + 1 } }
	x.report('Vector + Vector:')  { n.times { vector1 + vector2 } }
end

