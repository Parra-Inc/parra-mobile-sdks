require 'xcodeproj'
project_path = 'Parra.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target_name = ARGV[0]
version = ARGV[1]

if target_name == nil
    puts "No target name supplied"
    exit
end

if version == nil 
    puts "No version supplied"
    exit
end

puts "Preparing to change version of target #{target_name} to #{version}"

begin
    project.targets.each do |target|
        if target.name == target_name
            target.build_configurations.each do |config|
                config.build_settings['MARKETING_VERSION'] = version
                config.build_settings['CURRENT_PROJECT_VERSION'] = (Integer(config.build_settings['CURRENT_PROJECT_VERSION']) || 1) + 1
            end        
        end
    end
    
    project.save()
    
    puts "Version of target #{target_name} has been changed to #{version}"
rescue StandardError => msg
    puts "Error: #{msg}"
end

