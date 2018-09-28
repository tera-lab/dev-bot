require 'http'
require 'discordrb'
require 'yaml'

config = YAML.load_file('config.yml')
bot = Discordrb::Commands::CommandBot.new(token:config['DISCORD_TOKEN'], prefix: ".")

class Discordrb::Events::MessageEvent
  def send_user_info(res)
    case res.code
    when 200
      user = res.parse()
      self.channel.send_embed do |embed|
        embed.color = 0x1e90ff

        embed.add_field(name: 'Unique', value: user['unique'], inline: true)
        embed.add_field(name: 'MAC', value: user['mac'], inline: true)

        if !user['mods'].empty?
          embed.add_field(name: 'Mods', value: user['mods'].map{|mod| "- #{mod}"}.join("\r"))
        end

        characters = user['characters'].map do |character|
          bot.find_emoji(character['job']).to_s() + character['name']
        end
        embed.add_field(name: "Characters(#{characters.size})", value: characters.join(', '))
      end
    when 404
      self.channel.send_embed do |embed|
        embed.color = 0xff4757
        embed.description = "not found"
      end
    end
  end
end

bot.ready do
  puts 'ready'
end

bot.command [:users, :u], in: '#bot' do |event, unique|
  event.send_user_info(HTTP.get("https://tera-lab.appspot.com/users/#{unique}"))
end

bot.command [:search, :s], in: '#bot' do |event, name|
  event.send_user_info(HTTP.get("https://tera-lab.appspot.com/users/search", params: {name: name}))
end

bot.run()