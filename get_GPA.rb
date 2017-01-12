require 'yaml'
require './lib/request.rb'
require './lib/score.rb'
require './lib/email.rb'

begin
  # Load accounts and password.
  profiles = YAML.load_file('public/account.yml')
rescue
  puts '未找到账号密码，请新建account.yml并存入账号密码'
  exit
end

mailer = Email.new

profiles.each do |pro|
  account = pro['account'].to_s
  password = pro['password'].to_s
  subs_email = pro['subs_email']
  subs_name = pro['subs_name']
  begin
    req = Request.new(account, password)
    req.download_score
    score = Score.new
  rescue => e
    # Just print the error message for running constanly.
    p e
    next
  end
  scores = score.score_list
  gpas = score.gpas
  unless subs_email.nil?
    begin
      mailer.send_GPA(subs_email, scores, gpas, subs_name)
    rescue => e
      p e
      puts "\033[31;1m邮件发送失败，请检查邮箱是否正确!\033[0m"
      next
    end
  end
end
