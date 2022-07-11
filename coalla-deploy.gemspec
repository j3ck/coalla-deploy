# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "coalla-deploy/version"

Gem::Specification.new do |s|
  s.name = "coalla-deploy"
  s.version = Coalla::Deploy::VERSION
  s.authors = ["coalla"]
  s.email = ["dev@coalla.ru"]
  s.homepage = "http://coalla.ru"
  s.summary = "Coalla deploy gem"
  s.description = "Coalla deploy gem"

  s.rubyforge_project = "coalla-deploy"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'railties', '~> 4.0'
  s.add_dependency 'thor', '~> 0.18'
  s.add_development_dependency 'bundler', '~> 1.3.5'
  s.add_development_dependency 'rails', '~> 4.0'
  s.add_development_dependency 'net-ssh', '~> 2.7'
  s.add_development_dependency 'net-scp', '~> 1.1'
end
