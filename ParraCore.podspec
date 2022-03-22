

PARRA_VERSION = '0.0.1'

PARRA_LICENSE = <<-LICENSE
Copyright (c) 2022 Parra, LLC.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.

LICENSE

Pod::Spec.new do |spec|
  spec.name                     = 'ParraCore'
  spec.version                  = "#{PARRA_VERSION}"
  spec.license                  = { :type => 'MIT', :text => PARRA_LICENSE }
  spec.homepage                 = 'https://github.com/Parra-Inc/parra-ios-sdk'
  spec.authors                  = 'Parra, LLC.'
  spec.summary                  = 'A suite of customer feedback tools that allow companies to aggregate user feedback and seamlessly integrate with their mobile apps.'
  spec.source                   = { :git => 'https://github.com/Parra-Inc/parra-ios-sdk.git', :tag => "#{PARRA_VERSION}" }
  spec.module_name              = 'ParraCore'
  spec.swift_version            = '5.6'
  spec.static_framework         = true

  spec.ios.deployment_target    = '13.0'

  spec.source_files             = 'ParraCore/**/*.{h,swift,md}'
  spec.resources                = 'ParraCore/**/*.{png,jpeg,jpg,ttf,storyboard,xib,xcassets}'
  spec.frameworks               = 'Foundation', 'UIKit'
  spec.pod_target_xcconfig      = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig     = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
