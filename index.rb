require './request.rb'
require './score.rb'

begin
  # 读取账号密码
  profile  = IO.readlines("account.txt")
  account = profile[0].chomp
  password = profile[1].chomp
rescue
  puts "未找到账号密码，请新建account.txt并存入账号密码，换行分割。"
  exit
end

# TODO: 这里这样写不是很合理
req = Request.new(account, password)
req.get_score
score = Score.new

# 格式化打印成绩
score.guide_score_list.each do |x|
  p x
end
p score.gpas
