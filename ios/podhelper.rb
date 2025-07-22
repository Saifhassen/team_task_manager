require 'fileutils'
require 'json'

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __dir__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. Run 'flutter pub get' first."
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT=(.*)/)
    return matches[1].strip if matches
  end

  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Run 'flutter pub get' first."
end

def flutter_ios_engine_podspec
  File.expand_path(File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios', 'Flutter.podspec'))
end

def install_all_flutter_pods(flutter_application_path)
  install_flutter_engine_pod
  install_flutter_plugin_pods(flutter_application_path)
end

def install_flutter_engine_pod
  pod 'Flutter', :podspec => flutter_ios_engine_podspec
end

def install_flutter_plugin_pods(flutter_application_path)
  symlinks_dir = File.expand_path('.symlinks', flutter_application_path)
  plugins_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')

  return unless File.exist?(plugins_file)

  plugins = JSON.parse(File.read(plugins_file))['plugins']
  plugins['ios'].each do |plugin|
    name = plugin['name']
    path = plugin['path']
    symlink = File.join(symlinks_dir, name)
    FileUtils.mkdir_p(symlinks_dir)
    FileUtils.rm_f(symlink)
    FileUtils.ln_s(path, symlink)
    pod name, :path => File.join(symlink, 'ios')
  end
end

def flutter_additional_ios_build_settings(target)
  target.build_configurations.each do |config|
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  end
end
