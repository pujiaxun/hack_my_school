require 'yaml'
require './lib/request.rb'
require './lib/schedule.rb'
require './lib/email.rb'
require './lib/icalendar.rb'

START_TIME_OF_CLASS = [8 * 3600,
                      8  * 3600 + 50 * 60,
                      9  * 3600 + 50 * 60,
                      10 * 3600 + 40 * 60,
                      11 * 3600 + 30 * 60,
                      14 * 3600,
                      14 * 3600 + 50 * 60,
                      15 * 3600 + 50 * 60,
                      16 * 3600 + 40 * 60,
                      18 * 3600 + 30 * 60,
                      19 * 3600 + 20 * 60,
                      20 * 3600 + 10 * 60]
END_TIME_OF_CLASS = [8 * 3600 + 45 * 60,
                    9  * 3600 + 35 * 60,
                    10 * 3600 + 35 * 60,
                    11 * 3600 + 25 * 60,
                    12 * 3600 + 15 * 60,
                    14 * 3600 + 45 * 60,
                    15 * 3600 + 35 * 60,
                    16 * 3600 + 35 * 60,
                    17 * 3600 + 25 * 60,
                    19 * 3600 + 15 * 60,
                    20 * 3600 + 05 * 60,
                    20 * 3600 + 55 * 60]

begin
  # Load accounts and password.
  profiles = YAML.load_file('public/account.yml')
rescue
  puts '未找到账号密码，请新建account.yml并存入账号密码'
  exit
end

default_start_day_string = '20170220'
begin
  puts "请输入开学上课日期，格式：#{default_start_day_string}，直接回车以使用默认值："
  start_day_string = gets.chomp.strip
  start_day_string = default_start_day_string if start_day_string.empty?
  start_day = Time.parse(start_day_string)
rescue ArgumentError
  puts "无法解析出正确的日期"
  retry
end

start_weekday = start_day.wday

mailer = Email.new

profiles.each do |pro|
  account = pro['account'].to_s
  password = pro['password'].to_s
  subs_email = pro['subs_email'].to_s
  subs_name = pro['subs_name'].to_s

  req = Request.new(account, password)
  req.download_schedule
  schedule = Schedule.new

  courses = schedule.courses

  icalendar = ICalendar.new
  courses.each do |f|
    # I found that some courses have two apart phases in a semester
    f[:week].each do |w|
      class_start_week = w.split('-').first.to_i
      class_end_week = w.split('-').last.to_i
      repeat = class_end_week - class_start_week + 1
      desc = ["任课教师：#{f[:teacher].join('/')}",
              "课程类型：#{f[:prop]}",
              "学分：#{f[:credit]}",
              "考试类型：#{f[:exam]}"].join('\n')

      # The value is the time at 0 o'clock on that day
      that_day = start_day + ((class_start_week - 1) * 7 + f[:weekday] - start_weekday) * 24 * 3600
      s_time = that_day + START_TIME_OF_CLASS[f[:order] - 1]
      e_time = that_day + END_TIME_OF_CLASS[f[:order] + f[:count] - 2]
      event = {
        summary: f[:name],
        location: f[:place] + f[:classroom],
        rrule: "FREQ=WEEKLY;COUNT=#{repeat}",
        description: desc,
        start_time: s_time.strftime("%Y%m%dT%H%M%S"),
        end_time: e_time.strftime("%Y%m%dT%H%M%S")
      }
      icalendar.add_event event
    end
  end

  ics_path = "result/schedule#{account}.ics"
  File.open(ics_path, 'w') do |f|
    f.syswrite(icalendar.publish)
  end
  mailer.send_calendar(subs_email, ics_path, subs_name)
end
