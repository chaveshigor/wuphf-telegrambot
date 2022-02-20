# frozen_string_literal: true

require './lib/telegram_bot'
require 'dotenv'
Dotenv.load

puts 'Bot running'
bot = TelegramBot.new
bot.run
