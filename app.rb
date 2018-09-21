require 'http'
require 'discordrb'
require 'yaml'

config = YAML.load_file('config.yml')
bot = Discordrb::Commands::CommandBot.new(token:config['DISCORD_TOKEN'], prefix: ".")

bot.ready{puts 'ready'}
bot.command :chars, in: '#bot' do |event, unique|
  characters = HTTP.get("https://tera-lab.appspot.com/user/#{unique}/characters").parse['characters'] rescue []
  if characters.empty?
    event.channel.send_embed do |embed|
      embed.color = 0xff4757
      embed.description = "characters not found for `#{unique}`"
    end
  else
    event.channel.send_embed do |embed|
      embed.color = 0x1e90ff
      embed.description = "characters for `#{unique}`"

      characters.map do |character|
        embed.add_field(
          name: bot.find_emoji(character['job']),
          value: character['name'],
          inline: true
        )
      end
    end
  end
end

bot.run()