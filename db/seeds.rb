
def parse_dependencies_for_path(path)
  path = path.gsub("#{ENV["ROOT_FILE_PATH"]}/", "")
  puts "Creating dependencies for #{path}..."
  return if SwiftFile.find_by(filename: path) != nil
  file = SwiftFile.create(filename: path)
  file.setup_dependencies
  puts "Dependencies created!"
  puts ""
end

path = File.expand_path(ENV["ROOT_FILE_PATH"])
swiftdep_paths = Dir.glob("#{path}/*.swiftdeps")

swiftdep_paths.each do |path|
  parse_dependencies_for_path(path)
end
