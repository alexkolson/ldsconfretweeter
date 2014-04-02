require 'twitter'

# construct client with our config
ldsgenconf = Twitter::REST::Client.new do |config|
    config.consumer_key        = "ImVo19PtwqH6kWkzecfIkw"
    config.consumer_secret     = "W6icdXtPS6ipWJukJgLUcjplBsjUqa37lrL6Xf52Y6U"
    config.access_token        = "275914972-YZfFIB5lfYLfjtu3DCE85yIxqbLwyJW7AiKt2aEK"
    config.access_token_secret = "LtYFECJe6LzYU4AoE4UlLyVV5O7HazR9tdDAR67M"
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

last_checked = File.open("last_checked.txt").read

ldsgenconf.search("#ldsconf", :since => last_checked).select { |tweet| not do_not_rt.include? tweet[:user][:id] }.each do |tweet|

    # if this is a retweet, make sure the original tweet is
    # not from an undesirable user.
    if tweet[:retweeted_status] && do_not_rt.include?(tweet[:retweeted_status][:user][:id])
        puts "Original tweet is from an undesirable user. Not retweeting."
        next
    end

    puts tweet[:user][:id]
    puts tweet[:id]
    puts tweet[:text]
    puts tweet[:created_at]
    #ldsgenconf.retweet(tweet[:id])
    count += 1
    #sleep(5)
end

puts count
puts last_checked
File.open("last_checked.txt", "w") do |file|
    file.puts Time.now.to_s + "\r\n"
end
