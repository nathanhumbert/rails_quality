namespace :quality do
  desc "Run quality tests"
  task(:test) do
    ENV['output'] = "txt"
    Rake::Task["quality:flog"].execute
    Rake::Task["quality:flay"].execute
    Rake::Task["quality:roodi"].execute
		Rake::Task["quality:notes"].execute
  end

  desc "Run quality tests"
  task(:report) do
    ENV['output'] = "html"
    Rake::Task["test:units:rcov"].execute
    Rake::Task["test:functionals:rcov"].execute

    Rake::Task["quality:flog"].execute
    Rake::Task["quality:flay"].execute
    Rake::Task["quality:roodi"].execute
  end

	desc "stats"
	task(:stats) do
		require 'plugins/rails_quality/lib/command_line_metric_output'
		CommandLineMetricOutput.new()
	end

  desc "Run Flog"
  task(:flog) do 
    require 'flog'
    flog_runner(30, ['app/models', 'app/helpers', 'lib']) 
    flog_runner(45, ['app/controllers'])
  end

  def flog_runner(threshold, dirs)
    flog = Flog.new
    flog.flog_files dirs
    average_threshold = threshold / 3.0
    puts "=============================================="
    puts "Flog output for #{dirs.join(", ")}:"
    puts "Method threshold: %4.1f \nAverage threshold: %4.1f" % [threshold, average_threshold]
    puts "Flog total: %17.1f" % [flog.total]
    puts "Flog method average: %8.1f" % [flog.average]
    puts ""
    bad_methods = flog.totals.select do |name,score|
      score > threshold
    end
    bad_methods.sort { |a,b| a[1] <=> b[1] }.each do |name, score|
      puts "%8.1f: %s" % [score, name]
    end
     
    puts "#{bad_methods.size} methods have a flog complexity > #{threshold}" unless bad_methods.empty?
    puts "Average flog complexity > #{average_threshold}" unless flog.average < average_threshold
    puts "=============================================="
    puts ""
  end

  desc "Run Flay"
  task(:flay) do
    require 'flay'
    puts "=============================================="
    puts "Flay output: "
    threshold = 25
    flay = Flay.new({:fuzzy => false, :verbose => false, :mass => threshold})
    flay.process(*Flay.expand_dirs_to_files(['app/models', 'app/helpers', 'lib']))
    flay.report

    puts "#{flay.masses.size} chunks of code have a duplicate mass > #{threshold}" unless flay.masses.empty?
    puts "=============================================="
    puts ""
  end

  desc "Run Roodi"
  task(:roodi) do
    require 'roodi'
    puts "=============================================="
    puts "Roodi output:"
    error_count = roodi_runner('roodi.yml', "app/models/*.rb lib/**/*.rb app/helpers/**.rb")
    error_count += roodi_runner('controllers_roodi.yml', "app/controllers/*.rb")
    puts "#{error_count} Errors"
    puts "=============================================="
  end

  def roodi_runner(config_file, patterns)
    runner = Roodi::Core::Runner.new
    runner.config = "#{RAILS_ROOT}/config/#{config_file}roodi.yml"
    %w(patterns).each do |pattern|
      Dir.glob(pattern).each { |file| runner.check_file(file) } 
    end
    runner.errors.each { |error| puts error}
    return runner.errors.length 
  end

	desc "Output notes from source"
	task(:notes) do
    puts "=============================================="
		puts "Fixme notes:"
		Rake::Task["notes:fixme"].execute
    puts "=============================================="
		puts "Todo notes:"
		Rake::Task["notes:todo"].execute
    puts "=============================================="
	end

end
