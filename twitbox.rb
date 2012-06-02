# encoding: utf-8

require 'rubygems'
require './twitter.rb'
require './event_output_stream.rb'

tokens = Twitter.get_tokens
$event_output_stream = EventOutputStream.new(
  Twitter.verify(tokens[:consumer], tokens[:access_token])
)

Twitter.each_post(tokens[:consumer], tokens[:access_token]) do |p|
  begin
    if p['retweeted_status'];   $event_output_stream.retweet(p)
    elsif p['delete']
    elsif p['friends']
    elsif ev = p['event']
      case ev
      when 'favorite';          $event_output_stream.favorite(p)
      when 'unfavorite';
      when 'follow';            $event_output_stream.follow(p)
      when 'list_member_added'; $event_output_stream.list_member_added(p)
      else; raise "retweet?"
      end
    else;                       $event_output_stream.tweet(p)
    end
  rescue
    puts "### parse error ###"
    puts p.inspect
  end
end


