require 'rubygems'
require 'discordrb'
require 'mechanize'

# 環境変数のLoad
bot = Discordrb::Commands::CommandBot.new(
    token: ENV["DISCORD_TOKEN"] ,
    client_id: ENV["DISCORD_CLIENT_ID"],
    prefix: ['/', '\\'],
    command_doesnt_exist_message: 'そんなコマンドはないよ'
)

bot.command :hello do |event|
    event.send_message("hallo,world! #{event.user.name}")
end

player_list = []

# ポプ子メッセージ
bot.command :hi do |event|
    popuko_img_list = Dir.glob("img/*")
    select_img_path = popuko_img_list[rand(popuko_img_list.length)]
    event.send_file(File.open(select_img_path, 'r'), caption: "#{event.user.name} !!!")
end

# Inamura
# bot.command :inamura do |event|
#     inamura_img_list = Dir.glob("inamura/*")
#     select_img_path = inamura_img_list[rand(inamura_img_list.length)]
#     event.send_file(File.open(select_img_path, 'r'), caption: "Hi, #{event.user.name} .")
# end

# Food写真提供
bot.command :food do |event|
    agent = Mechanize.new
    link = 'https://source.unsplash.com/random/featured/?Food,Plate'
    agent.get(link).save "pic.png"
    event.send_file(File.open("pic.png", 'r'), caption: "OK, #{event.user.name} .")
    sleep(3)
    delete = File.delete("pic.png")
end

#参加者追加コマンド
bot.command [:add, :addme] do |event, *code|
    #引数無しならユーザ名
    player_names = (code[0] ? code : [event.user.name])
    added_names = []
    canceled_names = []
    player_names.each do |n|
        if player_list.include?(n)
            canceled_names << n
        else
            player_list << n
            added_names << n
        end
    end
    messages = []
    if !added_names.empty?
        messages << "`#{added_names.join("`, `")}`を追加しました。"
    end
    if !canceled_names.empty?
        messages << "`#{canceled_names.join("`, `")}`は既に参加済み。"
    end
    event.send_message(messages.join("\n"))
    puts player_list
end

#発言者の居るボイスチャンネルのメンバーを全員参加者リストに追加
bot.command :addall do |event|
    if event.user.voice_channel.nil?
        event.send_message("発言者の居るボイスチャンネルのメンバーを追加するコマンドです。\nどこかのボイスチャンネルに入って使用してください。")
    else
        player_names = []
        event.user.voice_channel.users.each do |u|
            player_names << u.name
        end
        #ここからほとんどaddコマンドコピペ（どうにかしたい）
        added_names = []
        canceled_names = []
        player_names.each do |n|
            if player_list.include?(n)
                canceled_names << n
            else
                player_list << n
                added_names << n
            end
        end
        messages = []
        if !added_names.empty?
            messages << "`#{added_names.join("`, `")}`を追加しました。"
        end
        if !canceled_names.empty?
            messages << "`#{canceled_names.join("`, `")}`は既に参加済み。"
        end
        event.send_message(messages.join("\n"))
        puts player_list
        #コピペここまで
    end
end

#参加者削除コマンド
bot.command [:remove, :rm, :removeme, :rmme] do |event, *code|
    #引数無しならユーザ名
    player_names = (code[0] ? code : [event.user.name])
    removeed_names = []
    canceled_names = []
    player_names.each do |n|
        if player_list.include?(n)
            player_list.delete(n)
            removeed_names << n
        else
            canceled_names << n
        end
    end
    messages = []
    if !removeed_names.empty?
        messages << "`#{removeed_names.join("`, `")}`をリストから削除しました。"
    end
    if !canceled_names.empty?
        messages << "`#{canceled_names.join("`, `")}`はおらんで。"
    end
    event.send_message(messages.join("\n"))
    puts player_list
end

#参加者リスト表示コマンド
bot.command [:list, :ls] do |event, *code|
    player_name = code[0]
    if player_list.empty?
        event.send_message("誰もリストにはおらんよ")
    else
        event.send_message("```\n#{player_list.join("\n")}\n```")
    end
    puts player_list
end

#参加者リスト初期化
bot.command [:clear, :clr, :removeall, :rmall] do |event|
    player_list.clear
    event.send_message("初期化完了。")
end

#プレイヤーのチーム分け
bot.command [:grouping, :group, :gp] do |event|
    if player_list.length < 2
        event.send_message("二人以上の参加者が必要です...")
    else
        team_list = player_list.sort_by{rand}.each_slice((player_list.length + 1) / 2).sort_by{rand}
        event.send_message(<<"EOS"
__**【BlueTeam】**__
```
#{team_list[0].join("\n")}
```
__**【OrangeTeam】**__
```
#{team_list[1].join("\n")}
```
Good Luck, Have Fun!
EOS
        )
    end
end

#一発で発言者の居るボイスチャンネルメンバー全員のチーム分け
bot.command [:r6s, :r6] do |event|
    #参加者リストを保持
    tmp = player_list
    #専用リストを作る
    player_list = []
    if event.user.voice_channel.nil?
        event.send_message("発言者の居るボイスチャンネルのメンバーを参照するコマンドです。\nどこかのボイスチャンネルに入って使用してください。")
    else
        event.user.voice_channel.users.each do |u|
            player_list << u.name
        end
        #ここからgroupingコマンドコピペ（どうにかしたい）
        if player_list.length < 2
            event.send_message("二人以上の参加者が必要です...")
        else
            team_list = player_list.sort_by{rand}.each_slice((player_list.length + 1) / 2).sort_by{rand}
            event.send_message(<<"EOS"
__**【BlueTeam】**__
```
#{team_list[0].join("\n")}
```
__**【OrangeTeam】**__
```
#{team_list[1].join("\n")}
```
Good Luck, Have Fun!
EOS
            )
        end
    end
    #groupingコマンドコピペここまで
    #参加者リストを戻す
    player_list = tmp
    return
end

# 鬼ごっこ
bot.command :oni do |event, *code|
  oni_number = code[0].to_i
  puts oni_number
  if oni_number.kind_of?(Integer)
    break  if player_list.length < oni_number
    choise_number_list = [*(0..(player_list.length - 1))].sort_by{rand}
    sledge_number = choise_number_list[0]
    if oni_number == 1
      event.send_message("SLEDGE is #{player_list[sledge_number]}")
    elsif oni_number == 2
      twitch_number = choise_number_list[1]
      event.send_message("SLEDGE is #{player_list[sledge_number]}")
      event.send_message("TWITCH is #{player_list[twitch_number]}")
    elsif oni_number == 3
      twitch_number = choise_number_list[1]
      blitz_number  = choise_number_list[2]
      event.send_message("SLEDGE is #{player_list[sledge_number]}")
      event.send_message("TWITCH is #{player_list[twitch_number]}")
      event.send_message("BLITZ is #{player_list[blitz_number]}")
    end
  else
    event.send_message("数字をちゃんと入れてくだされ。")
  end
end

bot.run
