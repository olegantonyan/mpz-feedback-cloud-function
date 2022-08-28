require 'functions_framework'
require 'telegram/bot'

FunctionsFramework.http('mpz-feedback') do |request|
  data = JSON.parse(request.body.read)

  author = data.fetch('author', nil)
  text = data.fetch('text')
  sysinfo = data.fetch('sysinfo', nil)

  notification = ''
  notification += "#{author}: " if author
  notification += text
  notification += "\n\n#{sysinfo}" if sysinfo

  telegram_api_key = ENV.fetch('TELEGRAM_API_KEY')
  telegram_chat_id = ENV.fetch('TELEGRAM_CHAT_ID')
  Telegram::Bot::Client.run(telegram_api_key) do |bot|
    bot.api.send_message(chat_id: telegram_chat_id, text: notification)
  end

  notification
end
