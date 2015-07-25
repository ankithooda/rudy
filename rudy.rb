require 'json'
require 'net/http'

#TODO: Get this constants from a config file
REDDIT_URL = 'http://www.reddit.com'
HOT = 'hot'
NEW = 'new'
NOTIFY_TIME = 10

# Takes subreddit and post type whether hot or new
# subreddit['name']
# subreddit['msg']
def fetch_subreddit_latest_post subreddit, post_type
  begin

    puts "#{Time.now} : Fetching reddit posts for #{subreddit['name']}"

    post_list = []
    subreddit_url = "#{REDDIT_URL}/r/#{subreddit['name']}/#{post_type}.json?sort=new"
    result = Net::HTTP.get(URI.parse(subreddit_url))
    json_data = JSON.parse(result)
    json_data["data"]["children"].each do |post|
      post_list.push post["data"]["title"]
    end

    puts "#{Time.now} : Fetched #{post_list.length} posts"

    # Notify in groups of 5 posts, since notify-send uses a daemon
    # all the notify-send calls will queued
    post_list.each_slice(5).each do |posts|
      # Sanitize the message string
      notification_title = subreddit['msg']
      notification_message = posts.join('\n')

      # If it not a valid encoding then convert it into one
      # see here - http://stackoverflow.com/questions/29877310/invalid-byte-sequence-in-utf-8-argumenterror
      # then gsub it
      if !notification_message.valid_encoding?
        notification_message = notification_message.encode("UTF-16be", :invalid=>:replace, :replace=>"").encode('UTF-8')
      end
      notification_message.gsub!("'", "")

      `notify-send -t #{NOTIFY_TIME} '#{notification_title}' '#{notification_message}'`
    end

  rescue StandardError => e
    puts "#{e}"
    puts "#{e.backtrace.join("\n")}"
  end
end

def main

  # Send a message when startings
  `notify-send -t 3 Rudy has started`
  
  #TODO: Get this hash from a config file
  subreddit_list = [
    {'name' => 'programming',
      'msg' => 'Hot on /programming'
    },
    {
      'name' => 'compsci',
      'msg' => 'Hot on /compsci'
    }
  ]

  subreddit_list.each do |subreddit|
    fetch_subreddit_latest_post subreddit, HOT
  end
end

if __FILE__== $0
	begin
		main
	rescue Interrupt => e
		nil
	end
end
