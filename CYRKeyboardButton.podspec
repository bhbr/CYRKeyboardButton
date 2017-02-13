Pod::Spec.new do |s|
  s.name         =  'CYRKeyboardButton'
  s.version      =  '0.6'
  s.license      =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary      =  'A drop-in keyboard button that mimics the look, feel, and functionality of the native iOS keyboard buttons.'
  s.author       =  { 'Illya Busigin' => 'http://illyabusigin.com/', 'Ben Hambrecht' ⇒ 'http://www.hambrecht.ch' }
  s.source       =  { :git => 'https://github.com/bhbr/CYRKeyboardButton.git', :tag => '0.6' }
  s.homepage     =  'https://github.com/bhbr/CYRKeyboardButton'
  s.platform     =  :ios
  s.source_files =  'CYRKeyboardButton'
  s.requires_arc =  true
  s.ios.deployment_target = '7.0'
  s.dependency 'TurtleBezierPath'
end
