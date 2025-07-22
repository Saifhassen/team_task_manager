require 'fileutils'
require 'json'

def parse_KV_file(file, separator='=')
  file_abs_path = File.expand_path(file)
  if !File.exists? file_abs_path
    return [];
  end
  generated_key_values = {}
  skip_line_start_symbols = ["#", "/"]
  File.foreach(file_abs_path) do |line|
    next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }
    if separator == '='
      key_value = line.split(separator, 2)
    else
      key_value = line.split(/#{separator}/, 2)
    end
    if key_value.length == 2
      key = key_value[0].strip()
      value = key_value[1].strip()
      if ((value.start_with? '"') && (value.end_with? '"')) || ((value.start_with? "'") && (value.end_with? "'"))
        value = value[1..-2]
      end
      generated_key_values[key] = value
    end
  end
  return generated_key_values
end

def flutter_root
  generated_xcode_build_settings = parse_KV_file(File.join(__dir__, 'Generated.xcconfig'))
  if generated_xcode_build_settings.empty?
    puts "Generated.xcconfig must exist. If you're running pod install manually, make sure flutter pub get is executed first."
    exit
  end
  generated_xcode_build_settings['FLUTTER_ROOT']
end

def flutter_ios_engine_path
  File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios')
end

def flutter_ios_podspec_paths
  engine_dir = flutter_ios_engine_path
  Dir.glob(File.join(engine_dir, '**', '*.podspec'))
end

def flutter_install_all_ios_pods(flutter_application_path)
  if !File.exist?(File.join(flutter_application_path, '.packages'))
    raise "#{flutter_application_path} must be the root of your Flutter project. Run 'flutter pub get' in the project root."
  end

  # Add Flutter engine podspecs.
  podspec_paths = flutter_ios_podspec_paths
  if podspec_paths.empty?
    raise "Could not find any Flutter engine podspecs in #{flutter_ios_engine_path}. Run 'flutter precache' to download the necessary binaries."
  end

  podspec_paths.each do |podspec_path|
    podname = File.basename(podspec_path, '.podspec')
    pod podname, :path => podspec_path
  end

  # Add app-specific pods.
  symlinks_dir = File.join(flutter_application_path, '.symlinks')
  FileUtils.mkdir_p(symlinks_dir)
  plugins_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')
  plugin_pods = JSON.parse(File.read(plugins_file))["plugins"]["ios"]
  plugin_pods.each do |plugin|
    symlink = File.join(symlinks_dir, plugin["name"])
    FileUtils.rm_f(symlink)
    File.symlink(plugin["path"], symlink)
    pod plugin["name"], :path => File.join(symlinks_dir, plugin["name"])
  end
end

def flutter_additional_ios_build_settings(target)
  target.build_configurations.each do |build_configuration|
    build_configuration.build_settings['ENABLE_BITCODE'] = 'NO'
    build_configuration.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  end
end
