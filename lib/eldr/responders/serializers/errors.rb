module Eldr
  module Responders
    module Serializers
      class Errors
        attr_accessor :errors
        
        def initialize(errors)
          @errors = errors
        end

        def to_json
          {'errors' => errors.to_hash}.to_json
        end
      end
    end
  end
end
