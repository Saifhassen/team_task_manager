Pod::Spec.new do |s|
  s.name             = 'Flutter'
  s.version          = '1.0.0'
  s.summary          = 'Flutter Engine Framework'
  s.description      = <<-DESC
                       Flutter engine framework for iOS
                       DESC
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://storage.googleapis.com/flutter_infra_release/flutter/abcdef1234567890/ios/flutter.podspec' }
  s.platform         = :ios, '9.0'
  s.vendored_frameworks = 'Flutter.xcframework'
  s.preserve_paths   = 'Flutter.xcframework'
  s.source_files     = 'Flutter.xcframework'
  s.public_header_files = 'Flutter.xcframework/**/*.h'
  s.module_map       = 'Flutter.xcframework/module.modulemap'
end
