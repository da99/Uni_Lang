
# Inspired by: http://www.ruby-forum.com/topic/157102#692145
class Not_In_Pattern
	
	module Module

		attr_reader :target
		def initialize target
			@target = target
		end

		def gsub pattern_or_string, replace = nil, &blok
			offsets = []
			target.gsub(pattern_or_string) { |substr|
				offsets << $~.offset(0)
			}
			
			index = 0
			final = ''
			
			offsets.each { |pair|
				if pair.first > index
					piece = index_at( index, pair.first )
					args = [piece, replace].compact
					final << piece.gsub(*args, &blok)
				end
				final << index_at( *pair )
				index = pair.last
			}
			
			if index < target.size
				piece = index_at( index, target.size )
				args = [piece, replace].compact
				final << piece.gsub(*args, &blok)
			end

			final
		end

		def index_at first, last
			target[first, last-first]
		end
	end # === module

	include Module

end # === class


if $0 == __FILE__ || $0['bin/bacon']
	
	require 'rubygems'
	require 'bacon'
	require 'pp'

	MAN_HERO = /[a-zA-Z]+man/
	ONE_OR_TWO_WORDS = /\w+( +\w+)?/
	describe "Replacement in different positions of line" do

		it "replaces words in middle + end" do
			Not_In_Pattern.new("Green Arrow, Superman, Batman, Green Lantern").gsub(MAN_HERO) { |piece|
				piece.gsub(ONE_OR_TWO_WORDS, '...')
			}.should.equal("..., Superman, Batman, ...")
		end
		
		it "replaces words in front + end" do
			Not_In_Pattern.new("Superman, Green Arrow, Batman").gsub(MAN_HERO) { |piece|
				piece.gsub(ONE_OR_TWO_WORDS, '...')
			}.should.equal('Superman, ..., Batman')
		end

		it "replaces nothing if not found" do
			Not_In_Pattern.new("Superman, Batman").gsub(MAN_HERO) { |piece|
				piece.gsub(ONE_OR_TWO_WORDS, '...')
			}.should.equal('Superman, Batman')
		end

		it "replaces all if everything matches" do
			Not_In_Pattern.new("Green Arrow").gsub(MAN_HERO) { |piece|
				piece.gsub(ONE_OR_TWO_WORDS, '...')
			}.should.equal('...')
		end
			
	end


end
