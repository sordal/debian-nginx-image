require_relative 'build_info'
run BuildInfo

# use Rack::Static, :urls => ['/public'], :root => File.expand_path(File.dirname(__FILE__)) + '/public'
