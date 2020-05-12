class Pastee
  class Errors
    # Error for an unrecognized error code from the API.
    class UnknownError < StandardError
      def initialize(error_code, error_msg)
        @error_code = error_code
        @error_msg = error_msg
      end

      def message
        "Error code #{@error_code} (unknown): #{@error_msg}. Please report this unknown error to the developers of the pastee gem."
      end
    end

    # Error for error codes 400, 404, 405, and 406.
    class BadRequestError < StandardError
      def initialize(code)
        @code = code
      end

      def message
        "Error code #{@code}: Bad request."
      end
    end

    # Error for error code 401.
    class InvalidKeyError < StandardError
      def message
        'Error code 401: The key provided was invalid.'
      end
    end

    # Error for error code 403.
    class RequiresUserApplicationError < StandardError
      def message
        'Error code 403: This resource requires a UserApplication.'
      end
    end

    # Error for error code 429.
    class TooManyRequestsError < StandardError
      def message
        'Error code 429: Too many pastes have been submitted with the given API key.'
      end
    end

    # Error for error code 500.
    class InternalServerError < StandardError
      def message
        'Error code 500: There was a problem with the Pastee server.'
      end
    end

    # Error for error code 503.
    class ServiceUnavailableError < StandardError
      def message
        'Error code 503: The service is temporarily offline for maintenance.'
      end
    end
  end
end
