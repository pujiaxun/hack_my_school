require 'nokogiri'
require 'byebug'

# This class is response for parsing HTML into scores and calculating GPA
class Schedule
  REAL_ORDER = [0,1,3,6,8,10]

  attr_reader :courses

  def initialize
    @schedule_file = 'temp/schedule.html'
    @courses = []
    parse_course
  end

  private

    # rubocop:disable Metrics/AbcSize
    def parse_course
      page = Nokogiri::HTML(open(@schedule_file).read, nil, 'gbk')
      raws = page.css('tr.odd')
      noko_courses=[]
      raws.each do |x|
        if x.children.length > 20
          noko_courses << x.children
        else
          noko_courses << (noko_courses.last.slice(0..(-x.children.length-1)) + x.children)
        end
      end

      noko_courses.each do |m|
        course = {
          name: pure_text(m.children[2]),
          credit: pure_text(m.children[4]).to_f,
          prop: pure_text(m.children[5]),
          exam: pure_text(m.children[6]),
          teacher: pure_text(m.children[7]).delete(" ").split("*"),
          week: pure_text(m.children[12]).delete("周上 ").split(","),
          weekday: pure_text(m.children[13]).to_i,
          order: REAL_ORDER[pure_text(m.children[14]).to_i].to_i,
          count: pure_text(m.children[15]).to_i,
          place: pure_text(m.children[17]),
          classroom: pure_text(m.children[18])
        }
        @courses << course
      end
    end

    def pure_text(nokogiri)
      nokogiri.text.to_s.gsub("\u00A0", "").strip
    end

end
