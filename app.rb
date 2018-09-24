require 'http'
require 'discordrb'
require 'yaml'

config = YAML.load_file('config.yml')
bot = Discordrb::Commands::CommandBot.new(token:config['DISCORD_TOKEN'], prefix: ".")

bot.ready do
  puts 'ready'
end

bot.command [:characters, :chars, :c], in: '#bot' do |event, unique|
  characters = HTTP.get("https://tera-lab.appspot.com/users/#{unique}").parse()['characters'] rescue []
  if characters.empty?
    event.channel.send_embed do |embed|
      embed.color = 0xff4757
      embed.description = "characters not found for `#{unique}`."
    end
  else
    event.channel.send_embed do |embed|
      embed.color = 0x1e90ff
      embed.description = "characters for `#{unique}`."

      characters.map do |character|
        embed.add_field(
          name: bot.find_emoji(character['job']).to_s + character['name'],
          value: "Last Login: #{character['last_login'] || 'null'}",
          inline: true
        )
      end
    end
  end
end

bot.command [:search, :s], in: '#bot' do |event, name|
  res = HTTP.get("https://tera-lab.appspot.com/users/search", params: {name: name})
  case res.code
  when 200
    user = res.parse()
    event.channel.send_embed do |embed|
      embed.color = 0x1e90ff
      embed.description = "found."

      embed.add_field(name: 'Unique', value: user['unique'])
      embed.add_field(name: 'MAC', value: user['mac'])
      
      user['characters'].map do |character|
        embed.add_field(
          name: bot.find_emoji(character['job']).to_s + character['name'],
          value: "Last Login: #{character['last_login'] || 'null'}",
          inline: true
        )
      end
    end
  when 404
    event.channel.send_embed do |embed|
      embed.color = 0xff4757
      embed.description = "not found."
    end
  end
end

bot.run()