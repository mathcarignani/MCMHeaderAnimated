Pod::Spec.new do |s|
  s.name             = "MCMHeaderAnimated"
  s.version          = "1.0.0"
  s.summary          = "Easy way to header animations."
  s.description      = <<-DESC
                       Easy way to header animations.
                       DESC
  s.homepage         = "https://github.com/mathcarignani/MCMHeaderAnimated"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Mathias Carignani" => "mathcarignani@gmail.com" }
  s.source           = { :git => "https://github.com/mathcarignani/MCMHeaderAnimated.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mathcarignani'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Source/*.swift'
end
