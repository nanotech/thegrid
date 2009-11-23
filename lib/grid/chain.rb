module Grid

	# Provides an interface for manipulating a Layer
	# like the classic "Snake" game.
	#
	class Chain < Layer
		attr_accessor :max_size, :animated
		attr_reader :vectors, :layer

		include Enumerable

		def initialize(grid, start_at, max_size, animated,
					   color, head_color=color, head_image=nil, *args)

			super(grid, color, *args)

			@vectors = []
			@max_size = max_size
			@head_color = head_color.expand_gradient
			@head_image = head_image

			push start_at if start_at
			start_at ||= Vector(0,0)
			start_pos = start_at * @grid.increment

			@easer = Array.new(@max_size) do
				VectorEaser.new(start_pos, :out, :quad)
			end
			@moved = Array.new(@max_size) { start_at }
			@animated = animated
		end

		# Called by Layer#draw, specifies a different color for the head.
		def color_of(vect)
			@head_color if vect == head
		end

		# Calculate animation.
		def position_of(vect, world_pos, id)
			if @animated and @moved[id]
				blocks_moved = @moved[id] * @grid.increment
				easer = @easer[id]

				# Only set if we haven't set already
				if easer.target != blocks_moved
					easer.to(blocks_moved, 600)
				end

				easer.update
				world_pos - blocks_moved + easer.value
			end
		end

		# Like push, but adds relative to the chain's head.
		# Also animates movement.
		def move(vect)
			if @animated
				last_positions = []
				@vectors.each_index do |id|
					last_positions[id] = @vectors[id]
				end
			end

			if push vect + head and @animated
				@vectors.each_index do |id|
					last_position = last_positions[id] || @vectors[@vectors.size-2]
					@moved[id] += @vectors[id] - last_position
				end
			end
		end

		def draw
			@vectors.each_with_index do |vector, id|
				block = self[vector]

				color = color_of vector
				color ||= @color

				world_position = vector * @grid.increment
				animated_position = position_of vector, world_position, id
				world_position = animated_position if animated_position

				if @head_image and vector == head
					ImageBlock.draw(world_position, @grid.block_size, @zlevel, color, @head_image)
				else
					Block.draw(world_position, @grid.block_size, @zlevel, color)
				end
			end
		end

		# Adds a block to the head of the chain.
		def push(vect); add_with(:push, vect) end

		# Adds a block to the tail of the chain.
		def unshift(vect); add_with(:unshift, vect) end

		# Removes a block from the head of the chain.
		def pop; remove_with(:pop) end

		# Removes a block from the tail of the chain
		def shift; remove_with(:shift) end

		def head; @vectors.last end
		def tail; @vectors.first end

		alias last head
		alias first tail

		def head_block; self[head] end
		def tail_block; self[tail] end

		def each
			@vectors.each do |block|
				yield block
			end
		end

		private

		# Helper method for adding blocks to the chain.
		def add_with(method, vect)
			if vect < @grid.area and vect >= Vector(0,0)

				overlap = @vectors.index vect

				turn vect, :on
				@vectors.delete_at(overlap) if overlap
				@vectors.send(method, vect)

				if @max_size != 0 and !overlap and @vectors.size > @max_size
					shift
				end

				vect
			end
		end

		# Helper method for removing blocks from the chain
		def remove_with(method)
			vect = @vectors.send(method)
			return self.send(method) if @vectors.include? vect

			turn vect, :off
		end
	end
end
