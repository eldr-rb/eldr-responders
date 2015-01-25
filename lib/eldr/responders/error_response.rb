require_relative 'response'

module Eldr
  module Responders
    class ErrorResponse < Response
      def initialize(status, options={})
        @options = options
        set_status(status)
      end

      def call(env)
        [status, {}, [message]]
      end

      ## So Ruby Likes us
      def exception(message)
        StandardError.new(message)
      end
    end
  end
end
