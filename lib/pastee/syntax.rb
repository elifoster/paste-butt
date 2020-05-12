class Pastee
  class Syntax
    # @return [Integer]
    attr_reader :id

    # @return [String]
    attr_reader :short_name

    # @return [String]
    attr_reader :full_name

    # Creates a new object representing a Syntax on the Pastee website.
    # @param opts [Hash<String, Object>] The options hash. This is usually obtained by the Pastee API.
    # @option opts [Integer] 'id' The integer ID for this syntax.
    # @option opts [String] 'short' The shortened name for the syntax.
    # @option opts [String] 'name' The full name for the syntax.
    def initialize(opts = {})
      @id = opts['id']
      @short_name = opts['short']
      @full_name = opts['name']
    end
  end
end
