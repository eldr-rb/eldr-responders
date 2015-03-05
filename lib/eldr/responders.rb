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

    def send_file(local_file, status: 200, disposition: nil, filename: nil, dir: 'public')
      dir = self.configuration.public_dir if self.configuration.public_dir
      lp = local_file[0] == File::SEPARATOR ? local_file : File.expand_path(File.join(dir, local_file))
      halt 404 unless File.exist? lp

      response = Response.new
      response.set_status = status

      # Content-Type
      response['Content-Type'] = (MIME::Types.type_for(File.extname(lp))[0].content_type rescue 'plain/text')

      # Content-Disposition
      if disposition == :attachment or filename
        response['Content-Dispostion'] = "attachment; filename=#{(filename or File.basename(lp)}"
      end

      # Content-Length
      response['Content-Length'] = File.size(lp)

      response.body << File.read(lp)
      response
    end
  end
end
