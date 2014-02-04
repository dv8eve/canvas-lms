# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'lti_outbound'
  spec.version       = '0.0.1'
  spec.authors       = ['Brian Palmer']
  spec.email         = ['brianp@instructure.com']
  spec.summary       = %q{LTI consumer service}
  spec.homepage      = 'https://github.com/instructure/canvas-lms'
  spec.license       = 'AGPL'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'i18n', '0.6.8'
  spec.add_dependency 'oauth-instructure', '0.4.9'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end