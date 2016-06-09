require 'nokogiri'

class Score
  attr_reader :scorelist, :gpa

  def initialize(score_file = "score.html")
    @score_file = score_file
    parser_score
    get_GPA
  end

  private
    def get_GPA (only_required = true)
      sum_point = 0
      sum_credit = 0
      @scorelist.each do |s|
        if ((s["prop"] != "选修") || !only_required)
          sum_point += s["point"].to_f * s["credit"].to_f
          sum_credit += s["credit"].to_f
        end
      end
      @gpa = (sum_point / sum_credit).round(3)
    end

    def get_point (grade)
      #如果只包含了数字和小数点
      if grade.match(/[^\d\.]+/).nil?
        s = grade.to_i
        case s
        when 0...60
          0
        when 60..90
          ((s-60) / 5) * 0.5 + 2.0
        when 90..100
          5
        else
          9999999
        end
      else
        case grade
        when "优秀"
          5
        when "良好"
          4
        when "中等"
          3
        when "及格"
          2
        else
          0
        end
      end
    end


    def parser_score
      @scorelist = []
      page = Nokogiri::HTML(open(@score_file).read,nil,"gbk")
      subjects = page.css("tr.odd")
      subjects.each do |m|
        subject = {}
        subject["name"] = m.children[5].text.strip
        subject["eng_name"] = m.children[7].text.strip
        subject["credit"] = m.children[9].text.strip
        subject["prop"] = m.children[11].text.strip
        subject["grade"] = m.children[13].text.strip.slice!(0..-2)# 鬼畜的空白字符
        subject["point"] = get_point(subject["grade"]).to_s
        @scorelist << subject
      end
    end

end
