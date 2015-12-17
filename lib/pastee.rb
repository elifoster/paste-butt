require 'httpclient'
require 'json'
require_relative 'errors'

# This class contains interfaces to the standard Pastee API. For the beta API,
#   use the PasteeBeta class.
class Pastee
  # Creates a new instance of Pastee.
  # @param api_key
  # @param use_ssl [Boolean] Whether to use a secure SSL connection.
  def initialize(api_key, use_ssl = true)
    @url = use_ssl ? 'https://paste.ee/' : 'http://paste.ee/'
    @client = HTTPClient.new
    @key = api_key
  end

  # Submits a POST request to the URL.
  # @param paste [String] The raw paste content.
  # @param description [String] The description of the paste.
  # @param encrypted [Boolean] The encryption
  # @param expire [Fixnum] The number of minutes until it expires.
  # @param language [String] The language to use for syntax highlighting.
  # @return [String] The paste ID.
  def submit(paste, description, encrypted = false, expire = 0,
             language = nil)
    uri = URI.parse(URI.encode("#{@url}/api"))
    params = {
      key: @key,
      descripton: description,
      paste: paste,
      expire: expire,
      format: 'json'
    }
    params[:encrypted] = encrypted ? 1 : 0
    params[:language] = language unless language.nil?
    response = @client.post(uri, params)
    json = JSON.parse(response.body)
    p json
    if json['status'] == 'error'
      throw_error(json['error'])
    else
      json['paste']['id']
    end
  end

  private

  def throw_error(error)
    case error
    when 'error_no_key' then fail Pastee::Errors::NoKeyError
    when 'error_no_paste' then fail Pastee::Errors::NoPasteError
    when 'error_invalid_key' then fail Pastee::Errors::InvalidKeyError
    when 'error_invalid_language' then fail Pastee::Errors::InvalidLanguageError
    end
  end
end
