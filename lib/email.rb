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
    subject = "成绩订阅#{'——' + subs_name unless subs_name.empty?}"
    content = render_score(scores, gpa, diff)
    send_out(subs_email, subject, content)
    puts "\033[032;1m邮件已发送！\033[0m"
  end

  def send_GPA(subs_email, scores, gpas, subs_name = '')
    subject = "成绩订阅#{'——' + subs_name unless subs_name.empty?}"
    content = render_GPA(scores, gpas)
    send_out(subs_email, subject, content)
    puts "\033[032;1m邮件已发送！\033[0m"
  end

  private

    def send_out(subs_email, subject, content)
      account = @account
      Mail.deliver do
        from     account
        to       subs_email
        subject  subject
        html_part do
          content_type 'text/html; charset=UTF-8'
          body content
        end
      end
    end

    def init_email
      smtp_server = @smtp_server
      account = @account
      password = @password
      Mail.defaults do
        delivery_method :smtp,  address: smtp_server,
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
