require 'mechanize'
require 'rtesseract'
require 'mini_magick'
require 'byebug'

# this class is response for crawing data from the specified url
class Request
  def initialize(account, password)
    @account = account
    @password = password
    @login_url = 'http://202.119.113.135/loginAction.do'
    @vcode_url = 'http://202.119.113.135/validateCodeAction.do?random=0.666'
    @grade_url = 'http://202.119.113.135/gradeLnAllAction.do?type=ln&oper=fa'
    @guide_url = 'http://202.119.113.135/gradeLnAllAction.do?type=ln&oper=lnjhqk'
    @vcode_img = 'temp/validateCode.jpg'
    login
  end

  def download_score
    begin
      @agent.get(@guide_url).iframe.click.save! 'temp/guide_score.html'
      @agent.get(@grade_url).iframe.click.save! 'temp/credit_score.html'
      print '登陆成功 '
    rescue
      puts "\033[31;1m可能没有评估，不能获取成绩!\033[0m"
      raise 'NoAccess'
    end
  end

  private

    def login
      @agent = Mechanize.new
      login_page = @agent.get @login_url
      login_form = login_page.forms[0]
      login_form.field_with(name: 'zjh').value = @account
      login_form.field_with(name: 'mm').value = @password
      puts "正在登陆#{@account}"
      loop do
        # Download captcha picture
        v_code = @agent.get @vcode_url
        v_code.save! @vcode_img
        # Identify captcha
        v_input = identify
        print '#'
        next if v_input.length != 4
        login_form.field_with(name: 'v_yzm').value = v_input
        result_page = @agent.submit login_form
        result_text = result_page.parser.to_s.encode('UTF-8')

        if result_text.include?('密码不正确')
          puts "\n\033[31;1m登录失败!请检查密码！\033[0m"
          raise 'WrongPassword'
        elsif result_text.include?('验证码错误')
          next
        else
          puts ''
          break
        end
      end
    end

    def identify
      image = RTesseract.new(@vcode_img, processor: 'mini_magick', options: [:text])
      # Remove blank character
      image.to_s.strip.delete ' '
    end
end
