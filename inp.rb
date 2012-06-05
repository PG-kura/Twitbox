# encoding: utf-8

require 'rubygems'
require 'net/https'
require 'oauth'
require 'cgi'
require 'term/ansicolor'
require './wrap_twitter.rb'

PROMPT = '[post/rep/favs/RT/exit]: '

tokens = Twitter.get_tokens

class AbstractMode
  def prompt
    raise 'do not implemented'
  end

  attr_accessor :consumer, :access_token
end

class DefaultMode < AbstractMode

  def initialize(consumer, access_token)
    @consumer = consumer
    @access_token = access_token
  end

  def prompt
    '[post/fav/RT/del/exit]: '
  end
  
  def accept_command(cmd)
    if /^post ([\d]{18}) (.+)/ =~ cmd
      ret = Twitter.get_post(@consumer, @access_token, $1)
      if ret[:screen_name]
        Twitter.post(@consumer, @access_token, "@#{ret[:screen_name]} #{$2}", $1)
      end 
    elsif /^post (.+)/ =~ cmd
      Twitter.post(@consumer, @access_token, $1)
    elsif /^fav ([\d]{18})/ =~ cmd
      Twitter.favs(@consumer, @access_token, $1)
    elsif /^RT ([\d]{18})/ =~ cmd
      Twitter.retweet(@consumer, @access_token, $1)
    elsif /^del ([\d]{18})/ =~ cmd
      ret = Twitter.get_post(@consumer, @access_token, $1)
      if ret[:retweet_id]
        Twitter.destroy(@consumer, @access_token, ret[:retweet_id])
      else
        Twitter.destroy(@consumer, @access_token, $1)
      end
    elsif 'exit' == cmd or 'EXIT' == cmd
      return nil
    end
    self 
  end

end

mode = DefaultMode.new(tokens[:consumer], tokens[:access_token])
print mode.prompt
while line = (STDIN.gets)[0..-2]
  print mode.prompt
  mode = mode.accept_command(line)
  break if mode == nil
end
puts "" 

