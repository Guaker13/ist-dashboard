require 'dashing'
require 'dotenv'
Dotenv.load

configure do
  set :auth_token, ENV['AUTH_TOKEN']

  # See http://www.sinatrarb.com/intro.html > Available Template Languages on
  # how to add additional template languages.
  set :template_languages, %i[html erb]

  helpers do
    def protected!
      return if authorized?

      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)

      @auth.provided? &&
        @auth.basic? &&
        @auth.credentials &&
        @auth.credentials == [
          ENV.fetch('BASIC_AUTH_USERNAME'), ENV.fetch('BASIC_AUTH_PASSWORD')
        ]
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
