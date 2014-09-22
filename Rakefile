# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'alarm'
  app.info_plist['LSUIElement'] = true
  app.frameworks << 'AVFoundation'
  app.frameworks << 'CoreAudio'

  app.vendor_project('vendor/switchaudio', :static)
  app.vendor_project('vendor/switchvolume', :static)

  app.pods do
    pod 'SocketRocket'
    pod 'JSONKit'
  end
end

task :launch do
  system('open `find . | grep "[^spec]\.app$"`') 
end
