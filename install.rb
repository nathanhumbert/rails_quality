require 'fileutils'
src_config_file = File.join(File.dirname(__FILE__), "roodi.yml")
dest_config_file = File.join("config", "roodi.yml") 
FileUtils.cp(src_config_file, dest_config_file)

controllers_src_config_file = File.join(File.dirname(__FILE__), "controllers_roodi.yml")
controllers_dest_config_file = File.join("config", "controllers_roodi.yml") 
FileUtils.cp(controllers_src_config_file, controllers_dest_config_file)
