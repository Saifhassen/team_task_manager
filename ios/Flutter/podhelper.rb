require 'fileutils'

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __dir__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try running flutter pub get first."
end

def flutter_ios_engine_podspec
  File.expand_path(File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios_engine.podspec'))
end

def flutter_install_all_ios_pods(flutter_application_path)
  install_all_flutter_pods(flutter_application_path)
end

def install_all_flutter_pods(flutter_application_path)
  flutter_install_ios_engine_pod
  flutter_install_podspecs(flutter_application_path)
end

def flutter_install_ios_engine_pod
  pod 'Flutter', :podspec => flutter_ios_engine_podspec
end

def flutter_install_podspecs(flutter_application_path)
  Dir.glob(File.join(flutter_application_path, '.ios', 'Flutter', 'podspecs', '*.podspec')).each do |podspec|
    podname = File
