# encoding: utf-8

require 'net/https'
require 'oauth'
require 'cgi'
require 'json'

module Twitter

  def self.oauth_access(consumer, access_token, url)

    uri = URI.parse(url)

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.ca_file = './verisign.cer'
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.verify_depth = 5

    https.start do |https|
      request = Net::HTTP::Get.new(uri.request_uri)
      request.oauth!(https, consumer, access_token)

      https.request(request) do |response|
        response.read_body do |chunk|
          begin
            json = JSON.parse(chunk.strip)
            yield json
          rescue
            puts "#### Parse error ####"
            puts json.inspect
          end
        end
      end
    end
  end



  def self.read_tokens_from_settings
    ret = {}
    IO.foreach('./tokens.txt') do |line|
      if /(.+)=(.+)/ =~ line
        ret[$1] = $2
      end
    end
    raise unless ret.has_key?('access_token')
    raise unless ret.has_key?('access_token_secret')
    raise unless ret.has_key?('consumer_key')
    raise unless ret.has_key?('consumer_secret')
    ret
  end

  def self.get_tokens
    tokens = read_tokens_from_settings

    ret = {}

    ret[:consumer] = OAuth::Consumer.new(
      tokens['consumer_key'],
      tokens['consumer_secret'],
      :site => 'http://twitter.com'
    )

    ret[:access_token] = OAuth::AccessToken.new(
      ret[:consumer],
      tokens['access_token'],
      tokens['access_token_secret']
    )

    ret
  end

  def self.verify(consumer, access_token)
    ret = {}
    oauth_access(consumer, access_token, 'https://api.twitter.com/account/verify_credentials.json') do |res|
      ret[:id]          = res['id']
      ret[:name]        = res['name']
      ret[:screen_name] = res['screen_name']
    end
    ret
  end

  def self.each_post(consumer, access_token)
    oauth_access(consumer, access_token, 'https://userstream.twitter.com/2/user.json') do |post|
      yield post
    end
  end

  def self.expand_url(text, info_arr)
    ret = ""
    i = 0
    info_arr.each do |e|
      idx = e['indices']
      if idx[0] - i >= 1
        ret = ret + text[i..idx[0] - 1]
      end
      ret = ret + e['display_url']
      i = idx[1]
    end  
    ret + text[i..-1]
  end

  def self.decode_amps(text)
    text.gsub(/&gt;/, '>').gsub(/&lt;/, '<').gsub(/&quot;/, '\"').gsub(/&amp;/, '&')
  end

  def self.expand(text, info_arr)
    decode_amps(expand_url(text, info_arr))
  end

end


