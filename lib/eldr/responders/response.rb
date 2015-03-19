require 'forwardable'
require 'active_support/core_ext/object/json'
require 'r18n-core'
require_relative 'status_codes'

module Eldr
  module Responders
    class Response < Rack::Response
      include Eldr::Rendering
      include StatusCodes
      include R18n::Helpers

      attr_accessor :object, :options, :status, :env, :configuration

      def initialize(object, *options)
        @object = object
        raise ArgumentsError, "Don't pass empty objects to respond you silly goose!" if object.nil? or (object.is_a? Array and object.empty?)
        @options = options.extract_options!
        @options[:action] = options.first if options.first.is_a? Symbol

        ## Setup Response Stuff
        @status = 200
        @header = ::Rack::Utils::HeaderHash.new()

        @chunked = CHUNKED == @header[TRANSFER_ENCODING]
        @writer  = lambda { |x| @body << x }
        @block   = nil
        @length  = 0

        @body = []

        ::R18n.thread_set do
          locales = ::R18n::I18n.parse_http(env['HTTP_ACCEPT_LANGUAGE'])

          ::R18n::I18n.new(locales, ::R18n.default_places, off_filters: :untranslated, on_filters: :untranslated_html)
        end
      end

      def force_redirect?
        @options[:force_redirect] ||= false
      end

      def set_status(status=nil)
        if status.is_a?(Integer)
          status = status
        elsif status.is_a?(String)
          status = interpret_status(status)
        else
          status = interpret_status(options[:status]) if options.status
        end
      end

      def flash_notice(message)
        env['x-rack.flash'].notice = message
      end

      def flash_error(message)
        env['x-rack.flash'].error = message
      end

      def request
        env['eldr.request']
      end

      def accept
        env['rack-accept.request']
      end

      def plural_model_name
        human_model_name.to_s.downcase.pluralize
      end

      def redirect_location
        @options[:location] ||= '/' + human_model_name.pluralize
      end

      def action
        action   = @options[:action]
        action ||= env['eldr.route'].name

        if action.nil?
          action   = :create  if request.post?
          action   = :update  if request.put?
          action   = :destroy if request.delete?
          action   = :show    if request.get?
          action   = :index   if request.get? and object.is_a? Array
        end

        action
      end

      def message
        return @options[:message]         if @options[:message]
        return @options[:error_message]   if @options[:error_message]   and !valid?
        return @options[:success_message] if @options[:success_message] and valid?

        return object.errors.full_messages if !valid?

        if t.responder.send(plural_model_name).send(action).translated?
          return t.responder.send(plural_model_name).send(action, human_model_name)
        elsif t.responder.default.send(action).translated?
          return t.responder.send(plural_model_name).send(action, human_model_name)
        end

        raise StandardError, "No message found in locale for responder.#{plural_model_name}.#{action}"
      end

      def human_model_name
        obj   = object.first if object.is_a? Array
        obj ||= object

        if obj.class.respond_to?(:human)
          obj.class.human
        elsif obj.class.respond_to?(:human_name)
          obj.class.human_name
        else
          obj.class.name.underscore
        end
      end

      def valid?
        valid = true

        obj = object.first if object.is_a? Array
        obj ||= object

        # `valid?` method may override existing errors, so check for those first
        valid &&= (obj.errors.count == 0) if obj.respond_to?(:errors)
        valid &&= obj.valid? if obj.respond_to?(:valid?)
        valid
      end

      def redirect_back_or_default(default)
        @status = 303
        @header['Location']   = request.referrer unless request.referrer.blank?
        @header['Location'] ||= default
        @header['Location'] = default if force_redirect?
      end
    end
  end
end
