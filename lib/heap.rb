begin
	require 'priority_queue'

rescue LoadError
	class PriorityQueue
		def initialize
			clear
		end

		def clear
			@heap = [nil]
		end

		def pop
			case size <=> 1
			when -1
				nil
			when 0
				@heap.pop
			else
				extracted = @heap[1]
				@heap[1] = @heap.pop
				sift_down
				extracted
			end
		end

		def push(key, value)
			#elements.each do |element|
			@heap << [key, value]
			sift_up
			#end
		end

		def delete_min_return_key
			pop[0]
		end

		def size
			@heap.size - 1
		end

		def empty?
			@heap.size == 1
		end

		def inspect
			@heap[1..-1].inspect
		end

		def to_s
			if empty?
				"[empty heap]"
			else
				res, = to_s_rec(1)
				res.shift
				res.join "\n"
			end
		end

		private

		def sift_down
			i = 1
			loop do
				c = 2 * i
				break if c >= @heap.size

				c += 1 if c + 1 < @heap.size and (@heap[c + 1][1] <=> @heap[c][1]) < 0
				break if (@heap[i][1] <=> @heap[c][1]) <= 0

				@heap[c], @heap[i] = @heap[i], @heap[c]
				i = c
			end
		end

		def sift_up
			i = @heap.size - 1
			while i > 1
				p = i / 2
				break if (@heap[p][1] <=> @heap[i][1]) <= 0

				@heap[p], @heap[i] = @heap[i], @heap[p]
				i = p
			end
		end

		# rows1 and rows2 are arrays of strings (ascii-art), this method will merge
		# those into one array of strings.
		# The strings from rows1 / rows2 will start at p1 / p2 in the result.
		#
		# ex: merge_rows(["a", "b"], ["c", "d"], 1, 3) => [" a c", " b d"]
		# ex: merge_rows(["a", "b"], [], 1, 3) => [" a", " b"]
		# ex: merge_rows([], ["c", "d"], 1, 3) => ["   c", "   d"]
		def merge_rows(rows1, rows2, p1, p2)
			i = 0
			res = []
			while i < rows1.size || i < rows2.size
				res << " " * p1
				res.last << rows1[i] if i < rows1.size
				if i < rows2.size
					res.last << " " * [0, p2 - res.last.size].max
					res.last << rows2[i]
				end
				i += 1
			end
			res
		end

		# builds an ascii-art representation of the subtree starting at index
		# i in @heap
		#
		# returns two values: an array of strings (the ascii-art) and the length of
		# the longest string in that array (the width of the ascii-art)
		def to_s_rec(i)
			str = @heap[i].to_s
			str = " " if str.empty?

			if i*2 < @heap.size # has left child
				l, wl = to_s_rec(i*2)
			else
				return [["|".center(str.size) , str], str.size]
			end

			if i*2+1 < @heap.size # has right child
				r, wr = to_s_rec(i*2+1)
			else
				r, wr = [], -1
			end

			# merge the subtree ascii-arts
			sumw = wl + wr + 1
			w = [sumw, str.size].max
			indent = (w - sumw) / 2
			res = merge_rows(l, r, indent, indent + wl + 1)

			# build the connection between parent and children
			# the vertical bar:
			vert = "|".center(w)

			# the horizontal connection e.g. "+--+--+"
			con = res[0].gsub("|", "+")
			con[vert.index("|")] = ?+
			# convert spaces between pluses to minuses
			con.sub!(/\+(.+)\+/) { |s| s.gsub(" ", "-") }

			# put it all together
			[[vert, str.center(w), vert, con] + res, w]
		end

	end
end
