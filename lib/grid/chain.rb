module Grid

	# Provides an interface for manipulating a Layer
	# like the classic "Snake" game.
	#
	class Chain
		attr_accessor :vectors, :max
		attr_reader :layer

		include Enumerable

		def initialize(layer)
			@layer = layer
			@layer.helper = self
			@vectors = []
			@max = 5
			@easer = VectorEaser.new(Vector.new(0,0), :out, :quad)
			@moved = Vector.new(0,0)
		end

		# Called by Layer#draw
		def color(vect)
			if vect == head
				[0xffff9900, 0xffff9900, 0xccff0000, 0xccff0000]
			end
		end

		def position(vect, pos)
			blocks_moved = @moved * @layer.grid.increment

			# Only set if we haven't set already
			if @easer.target != blocks_moved
				@easer.to(blocks_moved, 600)
			end

			@easer.update
			pos - blocks_moved + @easer.value
		end

		# Like push, but moves relative to the chain's head.
		def move(vect)
			if push vect + head
				puts vect + head
				@moved += vect
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

		def head_block; @layer[head] end
		def tail_block; @layer[tail] end

		def each
			@vectors.each do |block|
				yield block
			end
		end

		private

		# Helper method for adding blocks to the chain.
		def add_with(method, vect)
			if vect < @layer.grid.area and vect >= Vector(0,0)

				overlap = @vectors.include? vect

				@layer.turn(vect, :on)
				@vectors.send(method, vect)

				if @max != 0 and !overlap and @vectors.size > @max
					shift
				end

				vect
			end
		end

		# Helper method for removing blocks from the chain
		def remove_with(method)
			vect = @vectors.send(method)
			return self.send(method) if @vectors.include? vect

			@layer.turn(vect, :off)
		end
	end
end
