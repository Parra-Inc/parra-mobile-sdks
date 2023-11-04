require 'xcodeproj'
project_path = 'Parra.xcodeproj'
project = Xcodeproj::Project.open(project_path)

version = ARGV[0]

if version == nil 
    puts "No version supplied"
    exit
end

puts "Preparing to change Parra version to #{version}"

begin
    project.targets.each do |target|
        if target.name == "Parra"
            target.build_configurations.each do |config|
                config.build_settings['MARKETING_VERSION'] = version
                config.build_settings['CURRENT_PROJECT_VERSION'] = (Integer(config.build_settings['CURRENT_PROJECT_VERSION']) || 1) + 1
            end        
        end
    end
    
    project.save()
    
    puts "Parra version has been changed to #{version}"
rescue StandardError => msg
    puts "Error: #{msg}"
end

