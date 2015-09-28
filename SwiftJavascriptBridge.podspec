Pod::Spec.new do |s|
  s.name             = 'SwiftJavascriptBridge'
  s.version          = '1.0.0'
  s.summary          = "An iOS bridge for sending messages between Swift and Javascript."
  s.description      = <<-DESC
  An iOS bridge for sending messages between Swift and Javascript.
  SwiftJavascriptBridge is a Swift interface for bridging between WKWebView (Swift) and WebKit (Javascript).
  SwiftJavascriptBridge can be use to send message from Switf to Javascript, from Javascript to Swift or to recieve messages in Swift from Javascript or in Javascript from Swift.
                       DESC
  s.summary          = 'An iOS bridge for sending messages between Swift and Javascript.'
  s.homepage         = 'https://github.com/Elgatomontes/SwiftJavascriptBridge'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'Gaston Montes' => 'gastonmontes@hotmail.com' }
  s.source           = { :git => "https://github.com/Elgatomontes/SwiftJavascriptBridge.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ElgatitoMontes'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SwiftJavascriptBridge' => ['Pod/Assets/*.png']
  }
  s.docset_url = 'https://github.com/Elgatomontes/SwiftJavascriptBridge'
  s.documentation_url = 'https://github.com/Elgatomontes/SwiftJavascriptBridge'
  s.ios.deployment_target = "8.0"
end
