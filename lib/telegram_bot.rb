# frozen_string_literal: true

require 'telegram/bot'
require 'uri'
require 'net/http'
require 'json'

# Class to control telegram bot
class TelegramBot
  def initialize
    @bot_token = ENV['TELEGRAM_TOKEN']
  end

  def start_talk(message, bot)
    message_text = "Olá, #{message.from.first_name}! Para receber seus WUPHFs, digite seu e-mail."
    bot.api.send_message(chat_id: message.chat.id, text: message_text)
  end

  def save_chat_id(message, bot)
    email = message.text

    begin
      uri = URI("#{ENV['APP_BASE_URL']}/auth_contacts/telegram")
      res = Net::HTTP.post_form(uri, 'email': email, 'chat_id': message.chat.id)
      status = JSON.parse(res.body, symbolize_names: true)[:status]
    rescue
      message_text = 'Poxa, estamos com algum problema interno. Tente outra vez daqui a pouco :('
      return bot.api.send_message(chat_id: message.chat.id, text: message_text)
    end

    message_text = 'Poxa, algo deu errado. Tenta outra vez daqui a pouquinho :('
    message_text = 'Opa, deu tudo certo. Agora você vai receber uns WUPHFs :)' if status
    bot.api.send_message(chat_id: message.chat.id, text: message_text)
  end

  def run
    Telegram::Bot::Client.run(@bot_token) do |bot|
      bot.listen do |message|
        start_talk(message, bot) if message.text.upcase == '/START'
        save_chat_id(message, bot) if message.text.include? '@'
      end
    end
  end
end
