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
# score.score_list.each do |x|
#   p x
# end
loop do
  print "\n请输入指令选择操作：0.退出 "
  score.score_list.length.times do |i|
    print "#{i+1}.第#{i+1}学期 "
  end
  print "\n"
  op = gets.chomp.to_i
  if op == 0
    exit
  elsif op > 0 && op <= score.score_list.length
    score.score_list[op-1].each do |s|
      puts s.select {|k,v| ["grade", "credit", "prop", "name"].include? k.to_s}.values.reverse.join("\t")
    end
    puts "第#{op}学期绩点为：#{score.gpas[op-1][:gpa]}"
  else
    puts "选项错误，请重新输入"
    next
  end
end
