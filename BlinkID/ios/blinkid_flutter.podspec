#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint blinkid_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'blinkid_flutter'
  s.version          = '8001.0.0'
  s.summary          = 'The BlinkID SDK for Flutter'
  s.description      = <<-DESC
  The BlinkID SDK is a comprehensive solution for implementing secure document scanning on the Flutter cross-platform. It offers powerful capabilities for capturing and analyzing a wide range of identification documents. The Flutter plugin consists of BlinkID, which serves as the core module, and the BlinkIDUX package that provides a complete, ready-to-use solution with a user-friendly interface.
                       DESC
  s.homepage         = 'http://microblink.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Microblink' => 'milan.paradina@microblink.com' }
  s.source           = { :path => '.' }
  s.source_files = 'blinkid_flutter/Sources/blinkid_flutter/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
   }
   
  s.swift_version = '5.0'
end
