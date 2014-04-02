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
    1120957878,
    1938332516,
    2228917754,
    74905200,
    181481087,
    262706123,
    1542095239,
    33072413,
    2396954142,
    1509949195,
    906809238,
    2344136461,
    633107679,
    896735924,
    239228991,
    1561570206,
    711157689,
    1977357787,
    24820235,
    237320196,
    382910432,
    2202958129,
    1320657432
]

count = 0

last_checked = File.open("last_checked.txt").read.split(" ")
last_checked_date = last_checked[0]
last_checked_time = last_checked[1].gsub(":", "")

checked = Time.now.to_s

ldsgenconf.search("#ldsconf", :since => last_checked_date).select { |tweet| not do_not_rt.include? tweet[:user][:id] }.each do |tweet|
    created_at = tweet[:created_at].to_s.split(" ")
    created_at_time = created_at[1].gsub(":", "")
    created_at_date = created_at[0]

    # if this tweet was created before the last time the bot ran,
    # do nothing.
    if created_at_time < last_checked_time || created_at_date != last_checked_date
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
    sleep(0.5)
end

word = "retweets"
action_helper = "were"

if count == 1
    word = "retweet"
    action_helper = "was"
end

puts "#{count} #{word} #{action_helper} attempted."

File.open("last_checked.txt", "w") do |file|
    file.puts checked + "\r\n"
end
