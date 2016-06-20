require "mechanize"
require 'rtesseract'
require 'mini_magick'
require 'byebug'

class Request
  def initialize(account, password)
    @account = account
    @password = password
    @login_url = "http://202.119.113.135/loginAction.do"
    @vcode_url = "http://202.119.113.135/validateCodeAction.do?random=0.666"
    @grade_url = "http://202.119.113.135/gradeLnAllAction.do?type=ln&oper=fa"
    @guide_url = "http://202.119.113.135/gradeLnAllAction.do?type=ln&oper=lnjhqk"
    @vcode_img = "temp/validateCode.jpg"
    login
  end

  def get_score
    begin
      @agent.get(@guide_url).iframe.click.save! "temp/guide_score.html"
      @agent.get(@grade_url).iframe.click.save! "temp/credit_score.html"
      print "登陆成功 "
    rescue
      puts "\033[31;1m可能没有评估，不能获取成绩!\033[0m"
      raise "NoAccess"
    end
    # puts "\033[032;1m成绩已下载成功！\033[0m"
  end


  private
    def login
      @agent = Mechanize.new
      login_page = @agent.get @login_url
      login_form = login_page.forms[0]
      # 填入账号密码
      login_form.field_with(name: "zjh").value = @account
      login_form.field_with(name: "mm").value = @password
      puts "正在登陆#{@account}"
      loop do
        v_code = @agent.get @vcode_url  #下载验证码
        v_code.save! @vcode_img # 保存验证码图片
        v_input = identify  # 识别验证码
        print "."
        next if v_input.length != 4 # 如果识别结果长度不为4，则重新请求验证码
        login_form.field_with(name: "v_yzm").value = v_input  # 填入验证码
        result_page = @agent.submit login_form  # 提交表单
        result_text = result_page.parser.to_s.encode("UTF-8") # 以UTF-8解析页面

        if result_text.include?("密码不正确")
          puts "\n\033[31;1m登录失败!请检查密码！\033[0m"
          raise "WrongPassword"
        elsif result_text.include?("验证码错误")
          next
        else
          puts ""
          # TODO: 这里没有详细的判断，暂时只遇到以上两种情况
          break
        end
      end

    end

    def identify
      image = RTesseract.new(@vcode_img, processor: "mini_magick",options: [:text])
      # 将识别的结果去掉空格和换行符
      image.to_s.strip.gsub(' ','')
    end

end
