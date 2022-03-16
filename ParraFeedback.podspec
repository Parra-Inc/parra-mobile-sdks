
Pod::Spec.new do |spec|
  spec.name                     = 'ParraFeedback'
  spec.version                  = '0.1.0'
  spec.license                  = { :type => 'MIT' } # TODO: Link to license
  spec.homepage                 = 'https://github.com/Parra-Inc/parra-ios-sdk'
  spec.authors                  = { 'Mick MacCallum' => 'mick@parra.io', 'Ian MacCallum' => 'ian@parra.io' }
  spec.summary                  = 'Suite of mobile analytics tools'
  spec.source                   = { :git => 'https://github.com/Parra-Inc/parra-ios-sdk.git', :tag => "#{spec.version}" }
  spec.module_name              = 'Parra'
  spec.swift_version            = '5.5'
  spec.static_framework         = true

  spec.ios.deployment_target    = '13.0'

  spec.source_files             = 'Feedback/*.swift' # TODO should this just be .h?
  spec.frameworks               = 'Foundation', 'UIKit'

  spec.dependency 'ParraCore', "~> #{spec.version}"
end
