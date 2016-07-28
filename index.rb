require 'yaml'
require './request.rb'
require './score.rb'
require './email.rb'

include Email
SLEEP_TIME = 7 * 60

begin
  # Load accounts and password.
  profiles = YAML.load_file('public/account.yml')
rescue
  puts '未找到账号密码，请新建account.yml并存入账号密码'
  exit
end

loop do
  profiles.each do |pro|
    account = pro['account'].to_s
    password = pro['password'].to_s
    subs_email = pro['subs_email']
    subs_name = pro['subs_name']
    begin
      # req = Request.new(account, password)
      # req.download_score
      score = Score.new
    rescue => e
      # Just print the error message for running constanly.
      p e
      next
    end
    current_score = score.score_list
    gpas = score.gpas
    unless File.exist?("result/#{account}.yml")
      # Create a file to record scores if it doesn't exist.
      puts "第一次查询 #{account} 成绩，初始化中..."
      File.open("result/#{account}.yml", 'wb') do |f|
        YAML.dump(current_score, f)
      end
    end
    # Load the scores queried last time.
    last_score = YAML.load_file("result/#{account}.yml")
    # Update it if (current_score & last_score) != current_score
    # Judge by method update? in order to avoid scores being withdrawed.
    if score.update?(last_score)
      puts "\033[032;1m有新的成绩！！！\033[0m"
      unless subs_email.nil?
        begin
          send_email(subs_email, current_score.last, gpas.last, subs_name)
        rescue
          puts "\033[31;1m邮件发送失败，请检查邮箱是否正确!\033[0m"
          next
        end
      end
      File.open("result/#{account}.yml", 'wb') do |f|
        YAML.dump(current_score, f)
      end
    else
      puts '未查询到新成绩'
    end
  end

  puts "开始睡觉，睡上#{SLEEP_TIME / 60}分钟"
  sleep SLEEP_TIME
  puts "\n睡醒了接着干 #{Time.new.strftime('%Y-%m-%d %H:%M')}"
end
