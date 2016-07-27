require 'nokogiri'

class Score
  attr_reader :score_list, :gpas

  def initialize
    @score_file = 'temp/credit_score.html'
    @guide_score_file = 'temp/guide_score.html'
    @credit_list = []
    @guide_score_list = []
    @gpas = []
    @score_list = []
    get_score
    get_GPA
  end

  def update?(last_score)
    last_name = last_score.last.map { |s| s[:name] }
    current_name = @score_list.last.map { |s| s[:name] }
    (current_name & last_name) != current_name
  end

  private

    def get_GPA(only_required = true)
      # Only compute required course by default
      @score_list.each do |s|
        sum_point = 0
        sum_credit = 0
        s.each do |c|
          unless c[:prop] == '选修' && only_required
            sum_point += c[:point].to_f * c[:credit].to_f
            sum_credit += c[:credit].to_f
          end
        end
        @gpas << {
          credit: sum_credit,
          # Avoid 0 / 0 (Maybe only optional courses occur in this semester)
          gpa: (sum_credit.zero? ? 0 : (sum_point / sum_credit)).round(3)
        }
      end
    end

    def get_point(grade)
      # only numbers and dots
      s = grade.to_i
      case s
      when 0...60
        0
      when 60..90
        ((s - 60) / 5) * 0.5 + 2.0
      when 90..100
        5.0
      else
        raise 'WrongScores'
      end
    end

    def get_score
      page = Nokogiri::HTML(open(@guide_score_file).read, nil, 'gbk')
      subjects = page.css('tr.odd')
      subjects.each do |m|
        next unless m.children[9] && m.children[9].text.strip.length == 8
        vals = [1, 3, 7, 9].map{ |i| m.children[i].text.slice(1..-1).strip }
        vals << get_point(vals[2]).to_s
        keys = [:cno, :name, :grade, :date, :point]
        @guide_score_list << Hash[keys.zip vals]
      end
      parser_credit # Get credit list of courses
      merge_by_name # Merge by course's name
      nest_with_date # Store into an 2D Array based on different semesters
    end

    def parser_credit
      page = Nokogiri::HTML(open(@score_file).read, nil, 'gbk')
      subjects = page.css('tr.odd')
      subjects.each do |m|
        subject = {}
        subject[:name] = m.children[5].text.strip
        subject[:eng_name] = m.children[7].text.strip
        subject[:credit] = m.children[9].text.strip
        subject[:prop] = m.children[11].text.strip
        @credit_list << subject
      end
    end

    def merge_by_name
      @guide_score_list.each do |g|
        @credit_list.each do |s|
          # Merge two hashes if courses' names are same.
          g.merge! s if g[:name] == s[:name]
        end
      end
    end

    def nest_with_date
      res = []
      z = 0
      second_semester = 500...1100
      flag = false
      @guide_score_list.each do |s|
        z += 1
        # The flag is true when second and false when first semester.
        # Change semester when flag changed.
        date = s[:date].slice(-4..-1).to_i
        res << (z - 1) unless flag == second_semester.include?(date)
        flag = second_semester.include?(date)
      end
      res << z
      res.length.times do |i|
        # Divide scores based on semester
        @score_list << @guide_score_list.slice((i.zero? ? 0 : res[i - 1])...res[i])
      end
    end
end
