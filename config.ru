Dir.glob('./lib/secure-note/**/*.rb').each { |f| require f }

run SecureNote::Application
