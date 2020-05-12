class Pastee
  # Wrapper class for pastes.
  class Paste
    # @return [Integer] The paste's ID.
    attr_reader :id

    # @return [String] The paste's description.
    attr_reader :description

    # @return [Integer] How many views the paste has.
    attr_reader :views

    # @return [DateTime] When this paste was created.
    attr_reader :created_at

    # @return [DateTime, NilClass] When this paste will expire, or nil if it never expires.
    attr_reader :expires_at

    # @return [Array<Pastee::Section>] An array of Sections for this paste.
    attr_reader :sections

    # Create a new Paste object. Used when creating new pastes and when getting existing pastes. For creating new
    # pastes, you only need to provide the description and sections, and optionally encrypted (defaults to false). The
    # rest will be created automatically by the pastee API. ID, views, created_at, and expires_at are created by pastee,
    # they are only here for receiving paste objects.
    # @param opts [Hash] Options hash. Keys can either be strings or symbols — they will be converted to symbols.
    # @option opts [String] :id Paste ID.
    # @option opts [Boolean] :encrypted Whether this paste is treated as encrypted. Pastee does not actually encrypt
    # pastes, this only affects how it appears on the website.
    # @option opts [String] :description The paste's description or name.
    # @option opts [Integer] :views How many times this paste has been viewed.
    # @option opts [String] :created_at When this paste was created, in string form. Is parsed into a DateTime.
    # @option opts [String] :expires_at When this paste expires, in string form. Is parsed into a DateTime.
    # @option opts [Array] :sections An array either of Section objects (if you are creating a new paste) or a hash
    # object (returned by the pastee API) to be turned into a Section object.
    def initialize(opts = {})
      # Standardize keys so that both the pastee API (which uses strings) and pastee-rb consumers (who use symbols) can
      # both use this method.
      opts = Hash[opts.map { |k, v| [k.to_sym, v] }]

      @id = opts[:id]
      @encrypted = opts[:encrypted] || false
      @description = opts[:description]
      @views = opts[:views]
      @created_at = DateTime.parse(opts[:created_at]) if opts[:created_at]
      @expires_at = DateTime.parse(opts[:expires_at]) if opts[:expires_at]
      # For creating our own pastes
      @sections = opts[:sections][0].is_a?(Section) ? opts[:sections] : opts[:sections].map { |o| Section.new(o) }
    end

    # @return [Boolean] Whether this paste is encrypted.
    def encrypted?
      @encrypted
    end

    # Converts this to a hash object. Used in submitting pastes.
    # @return [Hash]
    def to_h
      hash = {
        description: description,
        sections: sections.map(&:to_h)
      }
      hash[:id] = id if id
      hash[:encrypted] = encrypted?
      hash[:views] = views if views
      hash[:created_at] = created_at if created_at
      hash[:expires_at] = expires_at if expires_at

      hash
    end

    # Wrapper class for paste sections.
    class Section
      # @return [Integer] The ID for this section.
      attr_reader :id

      # @return [String] The short name of the syntax used in this section.
      attr_reader :syntax

      # @return [String] The name of the section.
      attr_reader :name

      # @return [String] Contents of the section.
      attr_reader :contents

      # @return [Integer] Size of the section in bytes.
      attr_reader :size

      # Create a new Section object. Used when creating new pastes and when getting existing pastes. For creating new
      # pastes, you only need to provide the name and contents and optionally syntax. The rest will be created
      # automatically by the pastee API or by our {#to_h} method (syntax defaults to "autodetect"). ID and size are
      # created by pastee, they are only here for receiving paste objects.
      # @param opts [Hash] Options hash. Keys can either be strings or symbols — they will be converted to symbols.
      # @option opts [Integer] :id Section ID.
      # @option opts [String] :syntax The syntax short name for this section.
      # @option opts [String] :name The name of this section.
      # @option opts [String] :contents The contents of this section.
      # @option opts [Integer] :size The size of this section.
      def initialize(opts = {})
        # Standardize keys so that both the pastee API (which uses strings) and pastee-rb consumers (who use symbols) can
        # both use this method.
        opts = Hash[opts.map { |k, v| [k.to_sym, v] }]

        @id = opts[:id]
        @syntax = opts[:syntax]
        @name = opts[:name]
        @contents = opts[:contents]
        @size = opts[:size]
      end

      # Converts this to a hash object. Used in submitting pastes.
      # @return [Hash]
      def to_h
        hash = {
          name: name,
          contents: contents
        }
        hash[:id] = id if id
        hash[:syntax] = syntax || 'autodetect'
        hash[:size] = size if size

        hash
      end
    end
  end
end

