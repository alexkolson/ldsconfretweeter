require 'twitter'

# construct client with our config
ldsgenconf = Twitter::REST::Client.new do |config|
    config.consumer_key        = "ImVo19PtwqH6kWkzecfIkw"
    config.consumer_secret     = "W6icdXtPS6ipWJukJgLUcjplBsjUqa37lrL6Xf52Y6U"
    config.access_token        = "275914972-YZfFIB5lfYLfjtu3DCE85yIxqbLwyJW7AiKt2aEK"
    config.access_token_secret = "LtYFECJe6LzYU4AoE4UlLyVV5O7HazR9tdDAR67M"
end

do_not_rt = ["134902940"]

ldsgenconf.search("#ldsconf", :since => Time.now.strftime("%Y-%m-%d")).each do |tweet|
    puts "#{tweet[:id]}"
    ldsgenconf.retweet(tweet[:id]) unless do_not_rt.include? tweet[:user][:id_str]
end