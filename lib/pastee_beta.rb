require 'httpclient'
require 'json'
require_relative 'syntax'

# Base class for the Pastee Beta API. Provides interfaces to all of the beta
#   APIs. Will eventually be transferred to the Pastee class once the API is
#   out of beta.
# @author Eli Clemente Gordillo Foster
# @since 2.0.0
class PasteeBeta
  URL = 'https://api.beta.paste.ee'

  # Initializes the PasteeBeta instance.
  # @author Eli Clemente Gordillo Foster
  # @param [String] The Application or UserApplication key. This can be changed
  #   with #set_new_key.
  # @return [void]
  def initialize(api_key)
    @key = api_key
    @client = HTTPClient.new
    @client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  # Resets the API key to a new value. Useful for when, for example, the
  #   UserApplication key is needed and not the base Application key.
  # @author Eli Clemente Gordillo Foster
  # @param [String] The new key to use.
  # @return [void]
  def set_new_key(new_key)
    @key = new_key
  end

  # Submits a new paste to the Pastee Beta website.
  # @author Eli Clemente Gordillo Foster
  # @param [String] The paste contents.
  # @param [String] The paste description.
  # @param [String] The paste's name.
  # @param [Boolean] Whether the paste is encrypted.
  # @param [String] The syntax highlight language. It is recommended to use the
  #   constants in PasteeBeta::Constants::Syntax in order to avoid errors.
  # @return [String] The new paste's ID.
  def submit(paste, description, name, encrypted = false,
                  language = PasteeBeta::Constants::Syntax::AUTODETECT)
    uri = URI.parse(URI.encode("#{URL}/v1/pastes"))
    params = {
      description: description,
      sections: [
        {
          name: name,
          syntax: language,
          contents: paste
        }
      ]
    }
    params[:encrypted] = encrypted ? 1 : 0
    header = { 'X-Auth-Token' => @key, 'Content-Type' => 'application/json' }
    response = @client.post(uri, params.to_json, header)
    json = JSON.parse(response.body)
    if json['success']
      return json['id']
    else
      throw_error(json['errors'])
    end
  end

  # Gets the UserApplication key for the provided user.
  # @author Eli Clemente Gordillo Foster
  # @param [String] The user's login handle.
  # @param [String] The password for that user.
  # @return [String] The user's UserApplication key.
  def get_user_key(username, password)
    uri = URI.parse(URI.encode("#{URL}/v1/users/authenticate"))
    params = {
      username: username,
      password: password,
      key: @key
    }
    response = @client.post(uri, params)
    json = JSON.parse(response.body)
    if json['success']
      return json['key']
    else
      throw_error(json['errors'])
    end
  end

  # Gets a list of paste IDs.
  # @author Eli Clemente Gordillo Foster
  # @param [Integer] The number of entries to get per page.
  # @param [Integer] The page number to begin at.
  # @return [Array<String>] All paste IDs in that page.
  # @todo wait for a response from nikki about why this isn't working, then fix
  def list_pastes(perpage = 25, page = 1)
    uri = URI.parse(URI.encode("#{URL}/v1/pastes"))
    params = {
      perpage: perpage,
      page: page,
      key: @key
    }
    response = @client.get(uri, params)
    json = JSON.parse(response.body)
    ret = []
    if json['success']
      json['data'].each do |h|
        ret << h['id']
      end
    else
      throw_error(json['errors'])
    end
    ret
  end

  # Gets information about a paste.
  # @author Eli Clemente Gordillo Foster
  # @param [String] The paste ID.
  # @return [Hash] The information for the paste, including id,
  #   encryption (boolean), description, view count, creation date, expiration
  #   date, and the sections.
  def get_paste(id)
    uri = URI.parse(URI.encode("#{URL}/v1/pastes/#{id}"))
    header = { 'X-Auth-Token' => @key }
    response = @client.get(uri, nil, header)
    json = JSON.parse(response.body)
    if json['success']
      return json['paste']
    else
      throw_error(json['errors'])
    end
  end

  # Deletes a paste permanently.
  # @author Eli Clemente Gordillo Foster
  # @param [String] The paste ID.
  # @return [void]
  def delete_paste(id)
    uri = URI.parse(URI.encode("#{URL}/v1/pastes/#{id}"))
    response = @client.delete(uri, key: @key)
    json = JSON.parse(response.body)
    throw_error(json['errors'][0]['message']) unless json['success']
  end

  private

  # Throws the according error based on the error message provided by the API.
  # @author Eli Clemente Gordillo Foster
  # @private
  # @param [String] The error message provided by the API.
  # @param [String] The field error parameter.
  # @raise [UndefinedApplicationKeyError] When the application key is nil.
  # @return [void]
  def fail_with(message, field = nil)
    case message
    when 'No application key supplied.'
      fail Pastee::Errors::Beta::UndefinedApplicationKeyError
    when "The selected #{field} is invalid." && !field.nil?
      fail Pastee::Errors::Beta::InvalidFieldError.new("The field #{field} is" \
                                                       ' invalid.', field)
    when 'No application key supplied.'
      fail Pastee::Errors::Beta::UndefinedApplicationKeyError
    when 'NotUserApplication'
      fail Pastee::Errors::Beta::RequiresUserApplicationError
    when 'Invalid application key.'
      fail Pastee::Errors::Beta::InvalidAppKeyError
    end
  end

  # Throws an error based on the error hash provided by the Pastee API.
  # @author Eli Clemente Gordillo Foster
  # @see #fail_with.
  # @private
  # @param [Hash] The error field provided by the API.
  # @return [void]
  def throw_error(errors)
    message = errors[0]['message']
    field = errors[0]['field'] if defined? errors[0]['field']
    fail_with(message, field)
  end
end
