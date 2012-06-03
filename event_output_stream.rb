# encoding: utf-8

require 'term/ansicolor'

class MentionEvents

  def initialize
    @ev = []
  end

  def push(type)
    @ev << {
      :time => Time.now,
      :type => type
    }
  end

  def to_s
    ret = ''
    @ev.each do |e|
      case e[:type]
      when :reply;              ret << 'Rp'
      when :favorite;           ret << '★ '
      when :retweet;            ret << 'RT'
      when :follow;             ret << 'Fo'
      when :list_member_added;  ret << 'Li'
      end
      ret << ' '
    end
    ret
  end

end


class EventOutputStream
  include Term::ANSIColor

  def initialize(user)
    @mention_events = MentionEvents.new
    @user           = user
  end

  attr_reader :user

  def tweet(p)
    screen_name = "@#{p['user']['screen_name']}"
    name        = p['user']['name']
    text        = Twitter.expand(p['text'], p['entities']['urls'])
    id          = p['id']
    ids         = p['entities']['user_mentions'].collect {|m| m['id']}

    if ids.include?(@user[:id])
     
      @mention_events.push(:reply)

      do_print do
        puts "#{red('mentioned from')} #{cyan(screen_name)} #{dark(name)} #{id}"
        puts "  #{text}"
      end
    else
      do_print do
        puts "#{cyan(screen_name)} #{dark(name)} #{id}"
        puts "  #{text}"
      end
    end
  end

  def retweet(p)
    prt             = p['retweeted_status']
    screen_name     = "@#{p['user']['screen_name']}"
    user_name       = p['user']['name']
    org_screen_name = "@#{prt['user']['screen_name']}"
    org_user_name   = prt['user']['name']
    org_user_id     = p['entities']['user_mentions'][0]['id']
    id              = prt['id']

    text = Twitter.expand(prt['text'], prt['entities']['urls'])

    if @user[:id] == org_user_id

      @mention_events.push(:retweet)

      do_print do
        puts "#{green('retweeted by')} #{cyan(screen_name)} #{dark(user_name)} #{id}"
        puts "  #{text}"
      end
    else
      do_print do
        puts "#{cyan(screen_name)} #{dark(user_name)} #{id}"
        puts "=> RTs #{cyan(org_screen_name)} #{dark(org_user_name)}"
        puts "  #{text}"
      end
    end
  end

  def favorite(p)
    screen_name       = "@#{p['source']['screen_name']}"
    name              = p['source']['name']
    text              = p['target_object']['text']
    be_faved_user_id  = p['target_object']['user']['id']

    if @user[:id] == be_faved_user_id

      @mention_events.push(:favorite)

      do_print do
        puts "#{yellow('★ faved by')} #{cyan(screen_name)} #{dark(name)}"
        puts "  #{text}"
      end
    end
  end

  def follow(p)
    screen_name = "@#{p['source']['screen_name']}"
    name        = p['source']['name']

    @mention_events.push(:follow)
      
    do_print do
      puts "#{green('followed by')} #{cyan(screen_name)} #{dark(name)}"
    end
  end

  def list_member_added(p)
    screen_name = "@#{p['target_object']['user']['screen_name']}"
    list_name   = p['target_object']['name']
    name        = p['target_object']['user']['name']

    @mention_events.push(:list_member_added)
    
    do_print do
      puts "#{green('added to')} #{cyan(screen_name)}/#{list_name}"
      puts "  by #{cyan(screen_name)} #{name}"
    end
  end

  def do_print
    print "\r"
    yield
    puts ""
    print @mention_events
  end
end


