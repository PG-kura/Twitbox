# encoding: utf-8

require 'rubygems'
require 'net/https'
require 'oauth'
require 'cgi'
require './wrap_twitter.rb'

tokens = Twitter.get_tokens

class AbstractMode
  attr_accessor :consumer, :access_token
end

class Post < AbstractMode

  def prompt
    print "post: "
  end

  def accept(str)
    if str.size > 140
      print "Over #{str.size - 140}: "
      false
    else
      Twitter.post(consumer, access_token, str)
      true
    end
  end

end

class Favs < AbstractMode

  def prompt
    print "favs id: "
  end

  def accept(str)
    true
  end
end

DEFAULT_PROMPT = "[post/favs/exit]: "

mode = nil
print DEFAULT_PROMPT
while line = (STDIN.gets)[0..-2]
  if mode
    if line == 'exit' or mode.accept(line)
      mode = nil
      print DEFAULT_PROMPT
    end
  else
    case line
    when 'post'; mode = Post.new
    when 'favs'; mode = Favs.new
    when 'exit'; break
    end
    if mode
      mode.consumer     = tokens[:consumer]
      mode.access_token = tokens[:access_token]
      mode.prompt
    end
  end
end


