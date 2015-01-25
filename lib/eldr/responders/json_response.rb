require_relative 'response'

module Eldr
  module Responders
    class JSONResponse < Response
      def initialize(obj, *options)
        super(obj, options)
        header['Content-Type'] = 'application/json'
      end

      def call(env, app: nil)
        @env = env
        @configuration = app.configuration if app.respond_to? :configuration

        if valid?
          write success_resp
        else
          write error_resp
        end

        self
      end

      def success_resp
        if Object.const_defined?("Serializers::#{serializer_name}")
          serialized_resp
        else
          object.to_json
        end
      end

      def serialized_resp
        if object.is_a? Array
          ::Serializers.const_get(serializer_name).new(object).to_json
        else
          ::Serializers.const_get(serializer_name).new([object]).to_json
        end
      end

      def serializer_name
        obj   = object.first if object.is_a? Array
        obj ||= object
        obj.class.to_s.capitalize.pluralize
      end

      def error_resp
        obj   = object.first if object.is_a? Array
        obj ||= object

        @status = 400
        if Object.const_defined?('Serializers::Errors')
          ::Serializers::Errors.new(obj.errors).to_json
        else
          ::Eldr::Responders::Serializers::Errors.new(obj.errors).to_json
        end
      end
    end
  end
end
