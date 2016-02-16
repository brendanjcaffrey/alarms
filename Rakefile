# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'Alarms'
  app.identifier = 'com.brendanjcaffrey.alarms'
  app.copyright = 'Copyright © 2014-2016 Brendan Caffrey. All rights reserved.'

  app.icon = 'alarm.icns'
  app.version = '1.0.0'

  app.info_plist['LSUIElement'] = true
  app.info_plist['NSAppleScriptEnabled'] = 'YES'
  app.info_plist['OSAScriptingDefinition'] = 'scripting.sdef'

  app.frameworks << 'Cocoa'
  app.frameworks << 'AVFoundation'
  app.frameworks << 'CoreAudio'

  app.vendor_project('vendor/lifx', :static)
  app.vendor_project('vendor/switchaudio', :static)
  app.vendor_project('vendor/switchvolume', :static)

  app.pods do
    pod 'SocketRocket', '= 0.3.1-beta2'
  end
end

task :kill do
  `kill -9 \`ps -ef | grep [A]larms | awk '{print $2}'\``
end

task :release do
  release_path = '/Applications/Alarms.app'
  found_apps = `find . | grep "Alarms.app$"`

  if !found_apps
    puts 'Unable to find built app, run rake first'
    exit 1
  end

  split = found_apps.split("\n")
  if split.count != 1
    puts 'Multiple apps found, run rake clean && rake to build only latest version'
    exit 2
  end

  built_path = split.first
  system("rm -r '#{release_path}'") if File.exists?(release_path)
  system("cp -r '#{built_path}' '#{release_path}'")
  system("open '#{release_path}'")
end
