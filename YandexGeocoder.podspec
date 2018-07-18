Pod::Spec.new do |s|
  s.name         = "YandexGeocoder"
  s.version      = "0.1.0"
  s.summary      = "Use Yandex Geocoding API for forward and reversed geocoding."
  s.homepage     = "https://github.com/exister/YandexGeocoder"
  s.license      = 'MIT'
  s.author       = { "Mikhail Kuznetsov" => "strelok.ru@gmail.com" }
  s.source       = { :git => "https://github.com/exister/YandexGeocoder.git" }
  s.platform     = :ios, '8.0'
  s.source_files = 'Classes/**/*.{h,m}'
  s.requires_arc = true
  s.weak_frameworks = 'CoreLocation'
  s.dependency 'AFNetworking', '~> 3.2'
end
