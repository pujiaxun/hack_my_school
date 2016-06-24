require 'yaml'
require './request.rb'
require './score.rb'
require './email.rb'

include Email
SLEEP_TIME = 7 * 60

begin
  # 读取账号密码
  profile = YAML.load_file("public/account.yml")
rescue
  puts "未找到账号密码，请新建account.yml并存入账号密码"
  exit
end

loop do
  profile.each do |pro|
    account = pro["account"].to_s
    password = pro["password"].to_s
    subs_email = pro["subs_email"]
    subs_name = pro["subs_name"]
    begin
      req = Request.new(account, password)
      req.get_score
      score = Score.new
    rescue Exception=>e
      # 顾全大局，直接跳过防止中断程序
      next
    end
    current_score = score.score_list
    gpas = score.gpas
    unless File.exist?("result/#{account}.yml")
      # 如果是第一次查询，不存在成绩文件，则新建
      puts "第一次查询 #{account} 成绩，初始化中..."
      File.open("result/#{account}.yml", "wb") {|f| YAML.dump(current_score, f) }
    end
    # 读取上次查询的成绩结果
    last_score = YAML.load_file("result/#{account}.yml")
    # 如果这次查询的结果和上次不同，则表示有新的成绩，发送邮件，并更新成绩文件
    # 更新：如果两次查询的交集不等于最近一次查询的结果，则更新，避免学校撤回成绩通知
    # if (current_score & last_score) != current_score
    if score.is_new?(last_score)
      puts "\033[032;1m有新的成绩！！！\033[0m"
      unless subs_email.nil?
        begin
          send_email(subs_email, current_score.last, gpas.last, subs_name)
        rescue
          puts "\033[31;1m邮件发送失败，请检查邮箱是否正确!\033[0m"
          next
        end
      end
      File.open("result/#{account}.yml", "wb") {|f| YAML.dump(current_score, f) }
    else
      puts "未查询到新成绩"
    end
  end

  puts "开始睡觉，睡上#{SLEEP_TIME/60}分钟"
  sleep(SLEEP_TIME)
  puts "\n睡醒了接着干 #{Time.new.strftime("%Y-%m-%d %H:%M")}"
end
