require 'httpclient'
require 'json'
require_relative 'pastee/errors'
require_relative 'pastee/paste'
require_relative 'pastee/syntax'

class Pastee
  BASE_URL = 'https://api.paste.ee/v1'.freeze
  # Creates a new instance of Pastee.
  # @param api_key [String] The API key for this application.
  def initialize(api_key)
    @client = HTTPClient.new(
      default_header: {
        'X-Auth-Token' => api_key,
        'Content-Type' => 'application/json'
      }
    )
  end

  # Obtains information for a Pastee syntax from its integer ID.
  # @param id [Integer] The ID for this syntax.
  # @return [Pastee::Syntax] The syntax object representative of this integer ID.
  # @raise (see #throw_error)
  def get_syntax(id)
    uri = URI.parse("#{BASE_URL}/syntaxes/#{id}")
    response = JSON.parse(@client.get(uri).body)
    return Pastee::Syntax.new(response['syntax']) if response['success']

    throw_error(response)
  end

  # Obtains a list of valid Pastee syntaxes.
  # @return [Array<Pastee::Syntax>] A list of syntax objects.
  # @raise (see #throw_error)
  def list_syntaxes
    uri = URI.parse("#{BASE_URL}/syntaxes")
    response = JSON.parse(@client.get(uri).body)
    return response['syntaxes'].map { |obj| Pastee::Syntax.new(obj) } if response['success']

    throw_error(response)
  end

  # Gets paste information from its string ID.
  # @param id [String] The paste ID to obtain information for.
  # @return [Pastee::Paste] The paste that is tied to the provided ID.
  # @raise (see #throw_error)
  def get_paste(id)
    uri = URI.parse("#{BASE_URL}/pastes/#{id}")
    response = JSON.parse(@client.get(uri).body)
    return Pastee::Paste.new(response['paste']) if response['success']

    throw_error(response)
  end

  # Submits a new paste to Pastee. Build a paste using Pastee::Paste and Pastee::Section and submit it. This new way of
  # creating and submitting pastes is a little more convoluted than with the legacy (non-sectional) API, so use the
  # following example as a guideline. {#submit_simple} is simpler and should be used for simple single-section pastes.
  # @example
  #   section1 = Pastee::Paste::Section.new(
  #     name: 'section 1', # syntax defaults to autodetect
  #     contents: 'Some text!'
  #   )
  #   section2 = Pastee::Paste::Section.new(
  #     name: 'section 2',
  #     syntax: 'ruby',
  #     contents: File.read('lib/pastee.rb')
  #   )
  #   section3 = Pastee::Paste::Section.new(
  #     name: 'section 3',
  #     syntax: 'markdown',
  #     contents: File.read('README.md')
  #   )
  #   paste = Pastee::Paste.new(
  #     encrypted: true,
  #     description: 'super secret paste',
  #     sections: [
  #       section1,
  #       section2,
  #       section3
  #     ]
  #   )
  #   pastee.submit(paste)
  # @param paste [Pastee::Paste] The paste (see example)
  # @return [String] The paste ID.
  # @raise (see #throw_error)
  # @see #submit_simple
  def submit(paste)
    uri = URI.parse("#{BASE_URL}/pastes")
    response = JSON.parse(@client.request(:post, uri, body: JSON.dump(paste.to_h)).body)
    return response['id'] if response['success']

    throw_error(response)
  end

  # Simple submission method. Transforms a name and text into a proper single-Section Paste object and submits it.
  # @param name [String] The paste's name.
  # @param text [String] The paste text.
  # @param encrypted [Boolean] Whether this paste should be treated as encrypted by pastee.
  # @return (see #submit)
  # @raise (see #throw_error)
  def submit_simple(name, text, encrypted = false)
    section = Pastee::Paste::Section.new(name: name, contents: text)
    paste = Pastee::Paste.new(description: name, sections: [section], encrypted: encrypted)
    submit(paste)
  end

  # Delete a paste.
  # @param id [String] The paste ID to delete.
  # @return [Boolean] True if it was successfully deleted.
  # @raise (see #throw_error)
  def delete(id)
    uri = URI.parse("#{BASE_URL}/pastes/#{id}")
    response = JSON.parse(@client.delete(uri).body)
    return true if response['success']

    throw_error(response)
  end

  # Get the user type for the currently authenticated user.
  # @return [String] The user type.
  # @raise (see #throw_error)
  def get_user_type
    uri = URI.parse("#{BASE_URL}/users/info")
    response = JSON.parse(@client.get(uri).body)
    return response['type'] if response['success']

    throw_error(response)
  end

  private

  # Determines and raises the right error according to the error code provided by the pastee API.
  # @param response [Hash] The response object returned by the pastee API and parsed.
  # @raise [Pastee::Errors::BadRequestError] on 400, 404, 405, and 406.
  # @raise [Pastee::Errors::InvalidKeyError] on 401.
  # @raise [Pastee::Errors::RequiresUserApplicationError] on 403.
  # @raise [Pastee::Errors::TooManyRequestsError] on 429.
  # @raise [Pastee::Errors::InternalServerError] on 500.
  # @raise [Pastee::Errors::ServiceUnavailableError] on 503.
  # @raise [Pastee::Errors::UnknownError] if the error code is not recognized.
  def throw_error(response)
    error = response['errors'][0]
    error_code = error['code']
    error_msg = error['message']
    case error_code
    when 400 then raise Pastee::Errors::BadRequestError.new(error_code)
    when 401 then raise Pastee::Errors::InvalidKeyError
    when 403 then raise Pastee::Errors::RequiresUserApplicationError
    when 404 then raise Pastee::Errors::BadRequestError.new(error_code)
    when 405 then raise Pastee::Errors::BadRequestError.new(error_code)
    when 406 then raise Pastee::Errors::BadRequestError.new(error_code)
    when 429 then raise Pastee::Errors::TooManyRequestsError
    when 500 then raise Pastee::Errors::InternalServerError
    when 503 then raise Pastee::Errors::ServiceUnavailableError
    else raise Pastee::Errors::UnknownError.new(error_code, error_msg)
    end
  end
end
