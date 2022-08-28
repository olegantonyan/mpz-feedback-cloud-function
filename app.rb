# frozen_string_literal: true

require 'functions_framework'
require 'telegram/bot'

FunctionsFramework.http('mpz-feedback') do |request|
  data = JSON.parse(request.body.read)

  author = data.fetch('author', '')
  text = data.fetch('text')
  sysinfo = data.fetch('sysinfo', '')

  notification = ''
  notification += "#{author}: " unless author.empty?
  notification += text
  notification += "\n\n#{sysinfo}" unless sysinfo.empty?

  telegram_api_key = ENV.fetch('TELEGRAM_API_KEY')
  telegram_chat_id = ENV.fetch('TELEGRAM_CHAT_ID')
  Telegram::Bot::Client.run(telegram_api_key) do |bot|
    bot.api.send_message(chat_id: telegram_chat_id, text: notification)
  end

  notification
end
