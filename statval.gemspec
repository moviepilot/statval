# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'statval/version'

Gem::Specification.new do |s|
  s.name        = 'statval'
  s.version     = StatVal::VERSION
  s.summary     = 'Very simple statistics collector'
  s.description = 'Utility class for incrementally recording measured values and reporting avg, variance, min, and max'
  s.author      = 'Stefan Plantikow'
  s.email       = 'stefanp@moviepilot.com'
  s.homepage    = 'https://github.com/moviepilot/statval'
  s.rubyforge_project = 'statval'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.bindir      = 'script'
  s.executables = `git ls-files -- script/*`.split("\n").map{ |f| File.basename(f) }
#  s.default_executable = 'statval'
  s.licenses = ['PUBLIC DOMAIN WITHOUT ANY WARRANTY']
end
