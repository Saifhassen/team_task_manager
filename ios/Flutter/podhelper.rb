require 'fileutils'
require 'json'

def parse_KV_file(file, separator = '=')
  return {} unless File.exist?(file)

  result = {}
  skip_line_start_symbols = ['#', '/']

  File.foreach(file) do |line|
    next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }

    key_value = line.strip.split(separator, 2)
    next unless key_value.length == 2

    key = key_value[0].strip
    value = key_value[1].strip.gsub(/\A['"]|['"]\Z/, '')
    result[key] = value
  end

  result
end

def flutter_root
  config = parse_KV_file(File.expand_path('Generated.xcconfig', __dir__))
  unless config['FLUTTER_ROOT']
    abort('❌ FLUTTER_ROOT not found. Did you run `flutter pub get`?')
  end
  config['FLUTTER_ROOT']
end

def flutter_ios_engine_path
  File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios')
end

def flutter_ios_podspec_paths
  Dir.glob(File.join(flutter_ios_engine_path, '**/*.podspec'))
end

def flutter_install_all_ios_pods(flutter_application_path)
  packages_path = File.join(flutter_application_path, '.packages')
  unless File.exist?(packages_path)
    abort("❌ '#{flutter_application_path}' must be the root of your Flutter project. Run `flutter pub get` first.")
  end

  podspecs = flutter_ios_podspec_paths
  if podspecs.empty?
    abort("❌ No podspecs found in #{flutter_ios_engine_path}. Run `flutter precache`.")
  end

  podspecs.each do |podspec_path|
    podname = File.basename(podspec_path, '.podspec')
    pod podname, :path => podspec_path
  end

  # إعداد روابط الإضافات (plugins)
  plugins_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')
  unless File.exist?(plugins_file)
    abort("❌ Missing .flutter-plugins-dependencies. Run `flutter pub get`.")
  end

  plugins = JSON.parse(File.read(plugins_file))['plugins']['ios']
  symlinks_dir = File.join(flutter_application_path, '.symlinks')
  FileUtils.mkdir_p(symlinks_dir)

  plugins.each do |plugin|
    plugin_name = plugin['name']
    plugin_path = plugin['path']
    symlink = File.join(symlinks_dir, plugin_name)
    FileUtils.rm_f(symlink)
    File.symlink(plugin_path, symlink)
    pod plugin_name, :path => symlink
  end
end

def flutter_additional_ios_build_settings(target)
  target.build_configurations.each do |config|
    config.build_settings['ENABLE_BITCODE'] = 'NO'
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
  end
end
