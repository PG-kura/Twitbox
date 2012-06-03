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
    '[post/fav/RT/exit]: '
  end
  
  def accept_command(cmd)
    if /^post (.+)/ =~ cmd
      Twitter.post(@consumer, @access_token, $1)
    elsif /^reps ([\d]+) (.+)/ =~ cmd
      ret = Twitter.get_post(@consumer, @access_token, $1)
      if ret[:screen_name]
        Twitter.post(@consumer, @access_token, "@#{ret[:screen_name]} #{$2}", $1)
      end
    elsif /^reps ([\d]+)/ =~ cmd
      puts "### 開発中..."
      ret = Twitter.get_post(@consumer, @access_token, $1)
      if ret[:screen_name]
        m = ReplyMode.new(@consumer, @access_token, {
          :in_reply_to_status_id => $1,
          :screen_name           => ret[:screen_name]
          })
        return m
      end
    elsif /^fav ([\d]+)/ =~ cmd
      Twitter.favs(@consumer, @access_token, $1)
    elsif /^RT ([\d]+)/ =~ cmd
      Twitter.retweet(@consumer, @access_token, $1)
    elsif 'exit' == cmd or 'EXIT' == cmd
      return nil
    end
    self 
  end

end

class ReplyMode < AbstractMode
  include Term::ANSIColor

  def initialize(consumer, access_token, params)
    @consumer               = consumer
    @access_token           = access_token
    @in_reply_to_status_id  = params[:in_reply_to_status_id]
    @screen_name            = params[:screen_name]
  end

  def prompt
    screen_name = "@#{@screen_name}"
    "[reply for #{cyan(screen_name)}]: "
  end

  def accept_command(cmd)
    if 'exit' == cmd or 'EXIT' == cmd
    else
      Twitter.post(@consumer, @access_token, cmd, @in_reply_to_status_id)
    end
    DefaultMode.new(@consumer, @access_token)
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

