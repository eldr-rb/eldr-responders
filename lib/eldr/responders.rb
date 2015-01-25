require 'eldr/sessions'
require 'eldr/rendering'
require 'rack/accept'
require 'rack/flash'
require 'r18n-core'

require_relative 'responders/serializers/errors'
require_relative 'responders/error_response'
require_relative 'responders/html_response'
require_relative 'responders/json_response'

R18n.default_places = File.join(__dir__, './responders/i18n/')
R18n.set('en')

module Eldr
  module Responders
    def accept
      env['rack-accept.request'] ||= Rack::Accept::Request.new(env)
      env['rack-accept.request']
    end

    def set_locale
      R18n::Filters.on(:named_variables)

      R18n.thread_set do
        R18n::I18n.default = ::I18n.default_locale.to_s
        locales = R18n::I18n.parse_http(env['HTTP_ACCEPT_LANGUAGE'])
      end
    end

    def respond(object, *options)
      set_locale

      if accept.media_type?('text/html')
        HTMLResponse.new(object, *options).call(env, app: self)
      else
        JSONResponse.new(object, *options).call(env, app: self)
      end
    end

    def halt(status, options = {})
      options = {message: options} if options.is_a? String
      raise ErrorRepsonse.new(status, options)
    end

    def self.included(klass)
      klass.use Rack::Accept if klass.respond_to? :use
      klass.include Eldr::Rendering unless klass.instance_methods.include? :render
    end
  end
end
