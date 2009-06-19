class RailsAppSourceMetrics
	require 'plugins/rails_quality/lib/directory_source_stats'

	CODE_SECTIONS = [
			{ :name => "Controllers", :directory => "app/controllers/" },
			{ :name => "Helpers", :directory => "app/helpers/" },
			{ :name => "Models", :directory => "app/models/" },
			{ :name => "Libraries", :directory => "lib/" },
			{ :name => "Integration Tests", :directory => "test/integration/" },
			{ :name => "Functional Tests", :directory => "test/functional/" },
			{ :name => "Unit Tests", :directory => "test/unit/" }
		]

	attr_reader :code_sections, :totals, :lines_of_code, :lines_of_test_code, :code_to_test_ratio
	
	def initialize
		@code_sections = CODE_SECTIONS
		@code_sections.each do |section|
			source_stats = DirectorySourceStats.new(RAILS_ROOT + "/" + section[:directory])
			section[:stats] = add_metrics_to_stats(source_stats.get_stats)
		end
		calculate_totals
	end


private
	def add_metrics_to_stats(stats)
		stats = methods_per_class(stats)
		stats = lines_of_code_per_method(stats)	
		return stats
	end

	def methods_per_class(stats)
		begin
			stats[:methods_per_class] = (stats[:methods] / stats[:classes])
		rescue
			stats[:methods_per_class] = 0
		end
		return stats
	end

	def lines_of_code_per_method(stats)
		begin
			stats[:lines_of_code_per_method] = (stats[:lines_of_code] / stats[:methods])
		rescue
			stats[:lines_of_code_per_method] = 0
		end
		return stats
	end

	def calculate_totals
		@lines_of_code = code_totals[:lines_of_code]
		@lines_of_test_code = test_totals[:lines_of_code]
		@code_to_test_ratio = @lines_of_test_code / @lines_of_code.to_f
		@totals = base_totals(@code_sections)
	end

	def test_totals
		test_code_sections = @code_sections.select { |section| section[:directory] =~ /^test/ }
		return base_totals(test_code_sections)
	end

	def code_totals
		test_code_sections = @code_sections.select { |section| section[:directory] !~ /^test/ }
		return base_totals(test_code_sections)
	end

	def base_totals(code_sections)
    total = { :lines => 0, :lines_of_code => 0, :classes => 0, :methods => 0 }
		code_sections.each { |section| section[:stats].each { |k, v| total[k] += v if total.has_key?(k) } }
		return add_metrics_to_stats(total)
	end

end
