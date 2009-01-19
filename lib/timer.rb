#
# Simple block execution delayer.
#
class Timer
	attr_accessor :wait

	def initialize(wait, &block)
		@start = milliseconds
		@wait = wait
		@block = block
		@finished = false
	end

	def update
		if time >= @wait and not @finished
			@block.call
			@finished = true
		end
	end

	def time
		milliseconds - @start
	end
end
