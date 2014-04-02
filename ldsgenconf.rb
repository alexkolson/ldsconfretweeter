require 'twitter'

# read and use our API and OAuth keys
keys = File.open("keys.txt", "r").readlines.map { |line| line.gsub("\n", "") }

# construct client with our config
ldsgenconf = Twitter::REST::Client.new do |config|
    config.consumer_key        = keys[0]
    config.consumer_secret     = keys[1]
    config.access_token        = keys[2] 
    config.access_token_secret = keys[3]
end

do_not_rt = [
    134902940, 
    79543857, 
    275914972, 
    2344076401, 
    973238479, 
    166001916, 
    1489117579,
    1120957878
]

count = 0

last_checked = File.open("last_checked.txt").read.split(" ")
last_checked_date = last_checked[0]
last_checked_time = last_checked[1].gsub(":", "")

ldsgenconf.search("#ldsconf", :since => last_checked_date).select { |tweet| not do_not_rt.include? tweet[:user][:id] }.each do |tweet|
    created_at_time = tweet[:created_at].to_s.split(" ")[1].gsub(":", "")

    # if this tweet was created before the last time the bot ran,
    # do nothing.
    if created_at_time < last_checked_time
        puts "tweet #{tweet[:id]} is too old. Not retweeting."
        next
    end

    # if this is a retweet, make sure the original tweet is
    # not from an undesirable user.
    if tweet[:retweeted_status] && do_not_rt.include?(tweet[:retweeted_status][:user][:id])
        puts "Original tweet is from an undesirable user. Not retweeting."
        next
    end

    puts "attempting to retweet #{tweet[:id]}."
    ldsgenconf.retweet(tweet[:id])
    count += 1
    sleep(5)
end

puts "#{count} retweets were attempted."

File.open("last_checked.txt", "w") do |file|
    file.puts Time.now.to_s + "\r\n"
end
