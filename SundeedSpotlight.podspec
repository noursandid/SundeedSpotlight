Pod::Spec.new do |s|
  s.name = 'SundeedSpotlight'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'An easily implemented spotlight library to walk the user through the features'
  s.homepage = 'https://github.com/noursandid/SundeedSpotlight/'
  s.authors = { 'Nour Sandid' => 'noursandid@gmail.com' }
  s.source = { :git => 'https://github.com/noursandid/SundeedSpotlight.git', :tag => s.version }
  s.documentation_url = 'https://github.com/noursandid/SundeedSpotlight/'
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'Library/**/*.swift'
  s.framework = 'SystemConfiguration'
end
