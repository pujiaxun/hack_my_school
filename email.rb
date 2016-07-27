module Email
  require 'mail'
  require 'yaml'
  require 'erb'

  def send_email(subs_email, scores, gpa, subs_name)
    email = YAML.load_file('public/email.yml')
    smtp_server = email['smtp_server']
    account = email['account']
    password = email['password']

    Mail.defaults do
      delivery_method :smtp,  address: smtp_server,
                              port: 25,
                              user_name: account,
                              password: password,
                              enable_ssl: true
    end

    Mail.deliver do
      from     account
      to       subs_email
      subject  "成绩订阅#{'——' + subs_name unless subs_name.nil?}"
      html_part do
        content_type 'text/html; charset=UTF-8'
        body beatify(scores, gpa)
      end
    end
    puts "\033[032;1m邮件已发送！\033[0m"
  end

  private

    def beatify(scores, gpa)
      @scores = scores
      @scores.sort! do |a, b|
        comp = (a[:prop] <=> b[:prop])
        comp.zero? ? (b[:credit] <=> a[:credit]) : comp
      end
      @gpa = gpa
      erb = ERB.new(File.read('public/email.erb'))
      erb.result(binding)
    end
end
