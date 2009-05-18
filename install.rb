src_config_file = File.join(File.dirname(__FILE__), "roodi.yml")
dest_config_file = File.join(dest_dir, "roodi.yml") 

FileUtils.cp(src_config_file, dest_config_file)
