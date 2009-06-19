class DirectorySourceStats
	def initialize(directory)
		@stats = { :lines => 0, :lines_of_code => 0, :classes => 0, :methods => 0 }
		if File.exists?(directory)
			calculate_directory_statistics(directory)
		end
	end

	def get_stats
		return @stats
	end

private

	def calculate_directory_statistics(directory)
		Dir.foreach(directory) do |file_name| 
			path = directory + "/" + file_name
			if subdirectory?(path) and !hidden?(file_name)
				calculate_directory_statistics(path)
			elsif source_file?(file_name)
				process_source_file(path)
			end
		end
	end

	def source_file?(file_name)
		file_name =~ /.*\.rb$/
	end

	def hidden?( file_name )
		file_name =~ /^\./
	end

	def subdirectory?(path)
		File.stat(path).directory?  
	end
	
	def process_source_file(path)
		file_handle = File.open(path)
		parse_source_file(file_handle)
		file_handle.close
	end

	def parse_source_file(file_handle)
		while line = file_handle.gets
			@stats[:lines]     += 1
			@stats[:classes]   += 1 if class_definition?(line)
			@stats[:methods]   += 1 if method_call?(line)
			@stats[:lines_of_code] += 1 unless whitespace_or_comment?(line)
		end
	end

	def class_definition?(line)
		return line =~ /^\s*class [A-Z]/
	end

	def method_call?(line)
		return ( line =~ /def [a-z]/ or shoulda_method_call?(line) or test_unit_method_call?(line) )
	end

	def shoulda_method_call?(line)
		return line =~ /^\s*should\s+(".*"|'.*')\s+do\s*$/
	end

	def test_unit_method_call?(line)
		return line =~ /^\s*test\s+(".*"|'.*')\s+do\s*$/
	end

	def whitespace_or_comment?(line)
		return line =~ /^\s*$/ || line =~ /^\s*#/
	end
end
