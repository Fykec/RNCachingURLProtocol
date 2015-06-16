Pod::Spec.new do |s|
  s.name         = "RNCachingURLProtocol+HybirdApp."
  s.version      = "0.0.1"
  s.summary      = "RNCachingURLProtocol+HybirdApp.."

  s.description  = <<-DESC
                   RNCachingURLProtocol+HybirdApp.
                   DESC
  s.homepage     = "https://github.com/Fykec/RNCachingURLProtocol"
  s.license      = 'MIT'
  s.author             = { "Foster Yin" => "yinjiaji110@gmail.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "git@github.com:Fykec/RNCachingURLProtocol.git", :tag => "0.0.1" }
  s.source_files  = 'Classes', '*.{h,m}'
  s.requires_arc = true
  s.frameworks = 'SystemConfiguration'
  s.dependency 'EGOCache'
end
