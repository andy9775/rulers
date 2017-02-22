# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rulers/version'

Gem::Specification.new do |spec|
  spec.name          = 'rulers'
  spec.version       = Rulers::VERSION
  spec.authors       = ['Andy']
  spec.email         = ['andy9775@gmail.com']

  spec.summary       = 'A ruby on rails clone'
  spec.homepage      = 'https://github.com/andy9775/rulers'

  spec.files         = Dir["**/*"].select { |f| File.file? f }  
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'rack'
end
