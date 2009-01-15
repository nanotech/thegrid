#!/usr/bin/env ruby

$LOAD_PATH.push '../lib/'

require 'test/unit'
require 'vector'

class VectorTest < Test::Unit::TestCase
	def setup
		@a = Vector.new(5, 5)
		@b = Vector.new(1, 10)
	end

	def test_vector_equals
		assert_equal Vector.new(6, 15), @a + @b
	end

	def test_vector_does_not_equal
		assert_not_equal Vector.new(10, 10), @a + @b
	end
end
