class CommandLineMetricOutput
	require 'plugins/rails_quality/lib/rails_app_source_metrics'

	def initialize
		metrics = RailsAppSourceMetrics.new()
		print_header
		metrics.code_sections.each { |section| print_section(section) }
		print_splitter
		print_totals(metrics)
	end


	def print_splitter
		puts "+----------------------+-------+-------+---------+---------+-----+-------+"
	end

	def print_header
		print_splitter
		puts "| Name                 | Lines |   LOC | Classes | Methods | M/C | LOC/M |"
		print_splitter
	end

	def print_section(section)
		puts "| #{section[:name].ljust(20)} "+ print_stats(section[:stats])
	end

	def print_totals(metrics)
		puts "| #{'Totals'.ljust(20)} "+ print_stats(metrics.totals)
		print_splitter
		puts "  Code LOC: #{metrics.lines_of_code}     Test LOC: #{metrics.lines_of_test_code}     Code to Test Ratio: 1:#{sprintf("%.1f", metrics.code_to_test_ratio)}"
		puts ""
	end

	def print_stats(stats)
			 "| #{stats[:lines].to_s.rjust(5)} " +
			 "| #{stats[:lines_of_code].to_s.rjust(5)} " +
			 "| #{stats[:classes].to_s.rjust(7)} " +
			 "| #{stats[:methods].to_s.rjust(7)} " +
			 "| #{stats[:methods_per_class].to_s.rjust(3)} " +
			 "| #{stats[:lines_of_code_per_method].to_s.rjust(5)} |"
	end

end
