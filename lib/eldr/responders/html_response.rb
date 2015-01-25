require_relative 'response'

module Eldr
  module Responders
    class HTMLResponse < Response
      def initialize(object, *options)
        super
      end

      def call(env, app: self)
        @env = env
        @configuration = app.configuration

        if put_or_post?
          put_or_post
        else
          write(Tilt.new(find_template(view_name)).render(self))
        end

        self
      end

      def put_or_post?
        request.post? or request.put?
      end

      def put_or_post
        @status = 303

        if valid?
          flash_notice(message)
          redirect_back_or_default(redirect_location)
        else
          flash_error(message)
          redirect_back_or_default(redirect_location)
        end
      end

      def view_name
        human_model_name.pluralize + '/' + action.to_s
      end
    end
  end
end
