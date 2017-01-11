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
          name: m.children[2].text.to_s.gsub("\u00A0", "").strip,
          credit: m.children[4].text.to_s.gsub("\u00A0", "").strip.to_f,
          prop: m.children[5].text.to_s.gsub("\u00A0", "").strip,
          exam: m.children[6].text.to_s.gsub("\u00A0", "").strip,
          teacher: m.children[7].text.to_s.gsub("\u00A0", "").strip.delete(" ").split("*"),
          week: m.children[12].text.to_s.gsub("\u00A0", "").strip.delete("周上 ").split(","),
          weekday: m.children[13].text.to_s.gsub("\u00A0", "").strip.to_i,
          order: REAL_ORDER[m.children[14].text.to_s.gsub("\u00A0", "").strip.to_i],
          count: m.children[15].text.to_s.gsub("\u00A0", "").strip.to_i,
          place: m.children[17].text.to_s.gsub("\u00A0", "").strip.to_s,
          classroom: m.children[18].text.to_s.gsub("\u00A0", "").strip
        }
        @courses << course
      end
    end

end
