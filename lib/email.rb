# Including methods for sending emails
class Email
  require 'mail'
  require 'yaml'
  require 'erb'

  def initialize
    email = YAML.load_file('public/email.yml')
    @smtp_server = email['smtp_server']
    @account = email['account']
    @password = email['password']
    init_email
  end

  def send_score(subs_email, scores, gpa, subs_name = '', diff = [])
    subject = "成绩订阅 #{subs_name}"
    content = render_score(scores, gpa, diff)
    send_out(subs_email, subject, content)
    puts "\033[032;1m成绩已发送到邮箱！\033[0m"
  end

  def send_GPA(subs_email, scores, gpas, subs_name = '')
    subject = "成绩订阅 #{subs_name}"
    content = render_GPA(scores, gpas)
    send_out(subs_email, subject, content)
    puts "\033[032;1mGPA已发送到邮箱！\033[0m"
  end

  def send_calendar(subs_email, ics_path, subs_name = '')
    subject = "课程表订阅 #{subs_name}"
    content = "请下载附件使用日历app导入，建议使用新建日历，以免和原有日程混乱。"
    send_out(subs_email, subject, content, ics_path)
    puts "\033[032;1m课程表已发送到邮箱！\033[0m"
  end

  private

    def send_out(subs_email, subject, content, attachment = nil)
      account = @account
      mail = Mail.new do
        from     account
        to       subs_email
        subject  subject
        html_part do
          content_type 'text/html; charset=UTF-8'
          body content
        end
      end
      mail.add_file(attachment) if attachment
      mail.deliver
    end

    def init_email
      smtp_server = @smtp_server
      account = @account
      password = @password
      Mail.defaults do
        delivery_method :smtp,
          address: smtp_server,
          port: 25,
          user_name: account,
          password: password,
          enable_ssl: true
      end
    end

    def render_score(scores, gpa, diff = [])
      @scores = scores
      @scores.sort! do |a, b|
        comp = (a[:prop] <=> b[:prop])
        comp.zero? ? (b[:credit] <=> a[:credit]) : comp
      end
      @gpa = gpa
      @diff = diff
      erb = ERB.new(File.read('public/email.erb'))
      erb.result(binding)
    end

    def render_GPA(scores, gpas)
      @scores = scores
      @scores.each do |s|
        s.sort! do |a, b|
          comp = (a[:prop] <=> b[:prop])
          comp.zero? ? (b[:credit] <=> a[:credit]) : comp
        end
      end
      @gpas = gpas
      erb = ERB.new(File.read('public/GPA.erb'))
      erb.result(binding)
    end
end
