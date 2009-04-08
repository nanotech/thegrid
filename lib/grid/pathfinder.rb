require 'heap'

module Grid

	# Detects collisions
	class Pathfinder
		attr_reader :world

		def initialize(stack)
			@stack = stack
			build_world
		end

		# @world Array Vector shortcut.
		def [](vect)
			@world[vect.x][vect.y] if @world[vect.x]
		end

		# Combine an entire stack into a single layer
		# that contains cost and walkablity information.
		def build_world
			@world = []

			@stack.each do |name, layer|
				friction_grid = layer.blocks.dup

				friction_grid.map! do |row|
					row.map do |block|
						if block
							layer.walkable ? block : false
						end
					end
				end

				friction_grid.each_with_index do |column, x|
					column.each_with_index do |block, y|
						@world[x] = [] unless @world[x]

						if @world[x][y].nil? or block == false

							@world[x][y] = block
						end
					end
				end
			end

			@world
		end

		# Positions that you can move to from a point;
		# right, down, left, and up.
		OFFSETS = [Vector(1, 0), Vector(0, 1), Vector(-1, 0), Vector(0, -1)]

		# Iterate over possible moves from vect.
		def each_neighbor_of(vect)
			OFFSETS.each do |offset|
				pos = vect - offset

				if pos < @stack.area and self[pos] and pos >= Vector(0,0)
					yield pos
				end
			end
		end

		# Slow, finds the best path, and 
		# usually looks nice.
		def djikstra(*args)
			find(*args) do |vect, g|
				f = g
			end
		end

		# Fast, finds the best path,
		# may be slightly ugly.
		def astar(start, finish, *args)
			find(start, finish, *args) do |vect, g|
				h = vect.manhatten(finish)
				f = g + h
			end
		end

		# Even faster, bad paths in some
		# cases, path is usually ugly.
		def greedy(*args)
			find(*args) do |vect, g|
				h = vect.manhatten(finish)
				f = h
			end
		end

		private

		# The search algorithm.
		def find(start, finish, costs={})
			return nil if start == finish

			open_set = PriorityQueue.new # all nodes that are still worth examining
			closed_set = {} # nodes we have already visited

			open_set.push [start, [], 0], 0
			spot = start

			return unless self[spot]

			until open_set.empty?

				# get node with minimum cost
				spot, path_so_far, cost_so_far = open_set.delete_min_return_key

				next if closed_set[spot.to_a] # already checked
				newpath = path_so_far + [spot]

				return [newpath, closed_set] if spot == finish

				each_neighbor_of(spot) do |newspot|
					node = self[newspot]

					next if closed_set[newspot.to_a] # already checked

					g = cost_so_far + (costs[spot] || 1)
					f = yield newspot, g

					open_set.push [newspot, newpath, g], f
				end

				closed_set[spot.to_a] = true
			end
		end
	end
end
