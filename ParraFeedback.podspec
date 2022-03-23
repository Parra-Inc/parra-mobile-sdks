
VERSION = "#{ ENV['PARRA_FEEDBACK_VERSION'] }"
TAG = "#{ ENV['PARRA_FEEDBACK_TAG'] }"

Pod::Spec.new do |spec|
  spec.name                     = 'ParraFeedback'
  spec.version                  = "#{VERSION}"
  spec.license                  = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage                 = 'https://github.com/Parra-Inc/parra-ios-sdk'
  spec.authors                  = 'Parra, LLC.'
  spec.summary                  = 'A suite of customer feedback tools that allow companies to aggregate user feedback and seamlessly integrate with their mobile apps.'
  spec.source                   = { :git => 'https://github.com/Parra-Inc/parra-ios-sdk.git', :tag => "#{TAG}" }
  spec.module_name              = 'ParraFeedback'
  spec.swift_version            = '5.6'
  spec.static_framework         = true

  spec.ios.deployment_target    = '13.0'

  spec.source_files             = 'ParraFeedback/**/*.{h,swift,md}'
  spec.resources                = 'ParraFeedback/**/*.{png,jpeg,jpg,ttf,storyboard,xib,xcassets}'
  spec.frameworks               = 'Foundation', 'UIKit'

  spec.dependency 'ParraCore', '~>0.0.6'
end
