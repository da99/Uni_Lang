
class Property_Of_Noun
	
	include Sentence::Module

	def initialize
		super 'property-of-noun', "the [Word Prop] of [Noun]"
	end
	
	def compile line
		
		
		# Find property.
		# Raise if not found.
		prop_name = line.args['Prop'].value
		noun_name = line.args['Noun'].value
		noun = line.parent.detect_noun_named(noun_name)
		
		if not noun
			raise "Noun not found: #{noun_name}"
		end

		prop = noun.detect_property_named(prop_name)
		if not prop
			raise "Property of #{noun_name} not found: #{prop_name}"
		end

		# Save value to line arguments.
		val = prop.value
		obj_id = "ul-id-#{val.object_id}"
		line.carry_over_args[obj_id] = val

		# Replace partial sentence with reference to new argument.
		the_code = line.code_for_sentence_matcheing
		line.code_for_sentence_matcheing = the_code.sub(replace_pattern_regexp, obj_id)
		
	end


end # === class
