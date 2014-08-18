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

  app.pods do
    pod 'SocketRocket'
    pod 'JSONKit'
  end
end
