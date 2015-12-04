class Pastee
  class Errors
    class NoKeyError < StandardError
      def message
        'Error code 1: No key was provided.'
      end
    end

    class NoPasteError < StandardError
      def message
        'Error code 2: No paste content was provided.'
      end
    end

    class InvalidKeyError < StandardError
      def message
        'Error code 3: The key provided was invalid.'
      end
    end

    class InvalidLanguageError < StandardError
      def message
        'Error code 4: The syntax highlighting language provided was invalid.'
      end
    end

    class Beta
      class MustUseBetaError < StandardError
        def message
          'You must be using the Beta API for this action.'
        end
      end

      class UnauthorizedError < StandardError
        def message
          'The provided API key is incorrect.'
        end
      end

      class UndefinedApplicationKeyError < StandardError
        def message
          'You must provide an application key.'
        end
      end

      class InvalidFieldError < StandardError
        def initialize(msg, field)
          super(msg)
          @field = field
        end

        def message
          msg
        end
      end

      class RequiresUserApplication < StandardError
        def message
          'This resource requires a UserApplication.'
        end
      end

      class InvalidMethodError < StandardError
        def message
          'The endpoint was requested with an invalid method.'
        end
      end

      class InvalidFormatError < StandardError
        def message
          'The request was in a format other than XML or JSON.'
        end
      end

      class TooManyRequestsError < StandardError
        def message
          'Too many pastes have been submitted with the given API key.'
        end
      end

      class InternalServerError < StandardError
        def message
          'There was a problem with the Pastee server.'
        end
      end

      class ServiceUnavailableError < StandardError
        def message
          'The service is temporarily offline for maintenance.'
        end
      end
    end
  end
end
