class ICalendar
  def initialize(cal_name = '课程表' + Time.now.to_i.to_s)
    @version = 2.0
    @x_wr_calname = cal_name
    @x_apple_calendar_color = '#F64F00FF'
    @tzid = 'Asia/Shanghai'
    @x_lic_location = 'Asia/Shanghai'
    @events = []
  end

  def add_event(options={})
    default_event = {
      start_time: '20170420T080000',
      end_time: '20170420T093500',
      location: '地点',
      description: '备注\n详细描述',
      summary: "标题",
      rrule: 'FREQ=WEEKLY;COUNT=8'
    }
    @events << default_event.merge(options)
  end

  def publish
    gen_header + gen_events + gen_footer
  end

  private

  def gen_header
    header = <<-BAR
BEGIN:VCALENDAR
VERSION:#{@version}
X-WR-CALNAME:#{@x_wr_calname}
X-APPLE-CALENDAR-COLOR:#{@x_apple_calendar_color}
BEGIN:VTIMEZONE
TZID:#{@tzid}
X-LIC-LOCATION:#{@tzid}
END:VTIMEZONE
    BAR
  end

  def gen_events
    events_cal = @events.map do |e|
      event = <<-FOO
BEGIN:VEVENT
DTEND;TZID=#{@tzid}:#{e[:end_time]}
LOCATION:#{e[:location]}
DESCRIPTION:#{e[:description]}
SUMMARY:#{e[:summary]}
DTSTART;TZID=#{@tzid}:#{e[:start_time]}
RRULE:#{e[:rrule]}
END:VEVENT
      FOO
    end
    events_cal.join ""
  end

  def gen_footer
    "END:VCALENDAR\n"
  end

end
