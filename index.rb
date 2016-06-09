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
print "课程名　　　　　　　　\t学分\t得分\t绩点\n"
score.scorelist.each do |x|
  print x["name"].slice(0,10).concat("　　　　　　　　　　").slice(0,10) + "\t" + x["credit"] + "\t" + x["grade"] + "\t" + x["point"] + "\n"
  print "--------------------------------------------------\n"
end

print "必修课绩点为\033[32m" + score.gpa.to_s + "\033[0m\n\n"
