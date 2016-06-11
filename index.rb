require 'yaml'
require './request.rb'
require './score.rb'
require './email.rb'

include Email

begin
  # 读取账号密码
  # profile  = IO.readlines("public/account.txt")
  # account = profile[0].chomp
  # password = profile[1].chomp
  profile = YAML.load_file("public/account.yml")
  account = profile["student_id"].to_s
  password = profile["password"].to_s
rescue
  puts "未找到账号密码，请新建account.txt并存入账号密码，换行分割。"
  exit
end


# TODO: 这里这样写不是很合理
req = Request.new(account, password)
req.get_score
score = Score.new
current_score = score.score_list.dup
send_email(current_score.last)
# loop do
#   req = Request.new(account, password)
#   req.get_score
#   score = Score.new
#   if current_score != score.score_list
#     current_score = score.score_list.dup
#     send_email(current_score.last)
#   end
#   sleep(10*60)
# end
#
# loop do
#   print "\n请输入指令选择操作：0.退出 "
#   score.score_list.length.times do |i|
#     print "#{i+1}.第#{i+1}学期 "
#   end
#   print "\n"
#   op = gets.chomp.to_i
#   if op == 0
#     exit
#   elsif op > 0 && op <= score.score_list.length
#     score.score_list[op-1].each do |s|
#       puts s.select {|k,v| ["grade", "credit", "prop", "name"].include? k.to_s}.values.reverse.join("\t")
#     end
#     puts "第#{op}学期绩点为：#{score.gpas[op-1][:gpa]}"
#   else
#     puts "选项错误，请重新输入"
#     next
#   end
# end
