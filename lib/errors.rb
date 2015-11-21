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
  end
end
