require 'json'
require 'net/http'

REDDIT_URL = 'www.reddit.com'
HOT = 'hot'
NEW = 'new'
NOTIFY_TIME = 10

# Takes subreddit and post type whether hot or new
# subreddit['name']
# subreddit['msg']
def fetch_subreddit_latest_post subreddit, post_type
  begin
    post_list = []
    subreddit_url = "#{REDDIT_URL}/r/#{subreddit['name']}/#{post_type}.json?sort=new"
    result = Net::HTTP.get(URI.parse(subreddit_url))
    json_data = JSON.parse(result)
    json["data"]["children"].each do |post|
      post.push post["data"]["title"]
    end
  rescue StandardException => e
    puts "#{e}"
    puts "#{e.backtrace.join("\n")}"
  end
  `notify-send -t #{NOTIFY_TIME} #{subreddit['msg']} '#{post_list.join("\n")}'`
end

def main
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
    fetch_subreddit_last_post subreddit

    # Sleep for half minute before fetching next
    sleep NOTIFY_TIME + 30
  end
end

if __FILE__== $0
	begin
		main
	rescue Interrupt => e
		nil
	end
end
