
Pod::Spec.new do |s|

  s.name         = "SynologySwift"
  s.version      = "0.0.1"
  s.summary      = "Swift library for accessing Synology NAS and use DiskStation APIs"

  s.description  = <<-DESC
  Swift library for accessing Synology NAS. Resolve host/iP of your NAS and connect by APIs throught encryption service.
                   DESC

  s.homepage     = "https://github.com/Thomaslegravier/SynologySwift"
  s.license      = "MIT"

  s.author             = { "Thomas Le Gravier" => "legravier.thomas@gmail.com" }
  s.social_media_url   = "https://twitter.com/lebasalte"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.9"

  s.source       = { :git => "https://github.com/Thomaslegravier/SynologySwift.git", :tag => "#{s.version}" }
  s.source_files  = "*.swift"

end
