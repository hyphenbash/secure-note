Dir.glob('./lib/**/*.rb').each { |f| require f }

run SecureNote::Application
