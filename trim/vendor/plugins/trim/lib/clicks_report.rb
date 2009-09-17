##
# Written by Eric Woodward, ejw@nambu.com.
# Copyright 2008-2009. The Nambu Network Inc. All Rights Reserved.
##

require 'trim_country'
require 'user_browser'
require 'user_platform'

class ClicksReport
  attr_accessor :url_id, :url_site, :pchart_colour_fill
  attr_accessor :total_clicks, :clicks_humans, :clicks_bots, :lastvisits

  SITE_TRIM = 1
  SITE_PICIM = 2
  
  COUNTRIES_PER_PIE = 6
  REFERERS_PER_PIE = 5
  BROWSERS_PER_PIE = 6
  PLATFORMS_PER_PIE = 6

  MAX_DAYS_BARS = 12
  MAX_DAYS_LENGTH = 75
  MAX_HUMAN_CLICKS = 15
  
  ASPECT_TIMELINES = 0
  ASPECT_REFERERS = 1
  ASPECT_AGENTS = 2
  ASPECT_LOCATIONS = 3
  ASPECT_SUMMARIES = 4

  def initialize(url_id, url_site = SITE_TRIM, aspect = ASPECT_TIMELINES, pchart_colour_fill = "255, 102, 0")
    @url_id = url_id
    @url_site = url_site
    @pchart_colour_fill = pchart_colour_fill
    @trim_url, @picim_url, @total_clicks = nil, nil, 0
    @clicks_humans, @clicks_bots, @lastvisits = 0, 0, Array.new

    @click_months_names, @click_months_counts, @click_months_values = Array.new, Array.new, Array.new
    @click_dates_names, @click_dates_counts, @click_dates_values = Array.new, Array.new, Array.new
    @click_hours_names, @click_hours_counts, @click_hours_values = Array.new, Array.new, Array.new
    @click_referers_names, @click_referers_counts, @click_referers_values, @all_referers = Array.new, Array.new, Array.new, Array.new
    @click_countries_names, @click_countries_counts, @click_countries_values, @all_countries = Array.new, Array.new, Array.new, Array.new
    @click_browsers_names, @click_browsers_counts, @click_browsers_values, @all_browsers = Array.new, Array.new, Array.new, Array.new
    @click_platforms_names, @click_platforms_counts, @click_platforms_values, @all_platforms = Array.new, Array.new, Array.new, Array.new

    case self.url_site
    when SITE_TRIM
      @trim_url = TrimUrl.find(self.url_id)
    when SITE_PICIM
      @trim_url = PicimUrl.find(self.url_id) end

    case aspect
    when ASPECT_SUMMARIES
      set_summaries
    when ASPECT_TIMELINES
      set_locations
      set_timelines
    when ASPECT_REFERERS
      set_locations
      set_referers
    when ASPECT_AGENTS
      set_locations
      set_agents
    when ASPECT_LOCATIONS
      set_locations
    end
  end
  
  def set_locations
    case self.url_site
    when SITE_TRIM
      qs  = "SELECT country_id, COUNT(country_id) AS total FROM trim_clicks "
      qs << "WHERE trim_url_id = #{self.url_id} GROUP BY country_id ORDER BY total DESC LIMIT 2500"
      set_click_summaries_countries(qs)                                     ## Must go first for @total_clicks

    when SITE_PICIM
      qs  = "SELECT country_id, COUNT(country_id) AS total FROM picim_clicks "
      qs << "WHERE picim_url_id = #{self.url_id} GROUP BY country_id ORDER BY total DESC LIMIT 2500"
      set_click_summaries_countries(qs)                                     ## Must go first for @total_clicks
    end
  end
  def set_timelines
    case self.url_site
    when SITE_TRIM
      qs  = "SELECT YEAR(created_at) AS cyear, MONTH(created_at) AS cmon, COUNT(MONTH(created_at)) AS total FROM trim_clicks "
      qs << "WHERE trim_url_id = #{self.url_id} GROUP BY cmon ORDER BY cyear, cmon LIMIT 24"
      set_click_summaries_months(qs)

      qs  = "SELECT DATE(created_at) AS cdate, COUNT(DATE(created_at)) AS total FROM trim_clicks "
      qs << "WHERE trim_url_id = #{self.url_id} GROUP BY cdate DESC LIMIT #{MAX_DAYS_LENGTH}"
      set_click_summaries_dates(qs)

      qs  = "SELECT DAY(created_at) AS cday, HOUR(created_at) AS hday, COUNT(id) AS total FROM trim_clicks "
      qs << "WHERE trim_url_id = #{self.url_id} AND DATE(created_at) > '#{(DateTime.now).to_date - 3}' "
      qs << "GROUP BY cday, hday ORDER BY cday, hday DESC LIMIT 72"
      set_click_summaries_hours(qs)
      
    when SITE_PICIM
      qs  = "SELECT YEAR(created_at) AS cyear, MONTH(created_at) AS cmon, COUNT(MONTH(created_at)) AS total FROM picim_clicks "
      qs << "WHERE picim_url_id = #{self.url_id} GROUP BY cmon ORDER BY cyear, cmon LIMIT 24"
      set_click_summaries_months(qs)

      qs  = "SELECT DATE(created_at) AS cdate, COUNT(DATE(created_at)) AS total FROM picim_clicks "
      qs << "WHERE picim_url_id = #{self.url_id} GROUP BY cdate DESC LIMIT #{MAX_DAYS_LENGTH}"
      set_click_summaries_dates(qs)

      qs  = "SELECT DAY(created_at) AS cday, HOUR(created_at) AS hday, COUNT(id) AS total FROM picim_clicks "
      qs << "WHERE picim_url_id = #{self.url_id} AND DATE(created_at) > '#{(DateTime.now).to_date - 3}' "
      qs << "GROUP BY cday, hday ORDER BY cday, hday DESC LIMIT 72"
      set_click_summaries_hours(qs)
    end
  end
  def set_referers
    case self.url_site
    when SITE_TRIM
      qs  = "SELECT referer, COUNT(referer) AS total FROM trim_clicks "
      qs << "WHERE trim_url_id = #{self.url_id} GROUP BY referer ORDER BY total DESC LIMIT 2500"
      set_click_summaries_referers(qs)

    when SITE_PICIM
      qs  = "SELECT referer, COUNT(referer) AS total FROM picim_clicks "
      qs << "WHERE picim_url_id = #{self.url_id} GROUP BY referer ORDER BY total DESC LIMIT 2500"
      set_click_summaries_referers(qs)
    end
  end
  def set_agents
    case self.url_site
    when SITE_TRIM
      qs  = "SELECT p.id, b.id, COUNT(cc.id) AS cs FROM user_platforms p, user_browsers b, user_agents a, trim_clicks cc "
      qs << "WHERE cc.trim_url_id = #{self.url_id} AND cc.agent_id = a.id AND a.platform_id = p.id AND a.browser_id = b.id "
      qs << "GROUP BY b.id ORDER BY cs DESC LIMIT 2500"
      set_click_summaries_agents(qs)

    when SITE_PICIM
      qs  = "SELECT p.id, b.id, COUNT(cc.id) AS total FROM user_platforms p, user_browsers b, user_agents a, picim_clicks cc "
      qs << "WHERE cc.picim_url_id = #{self.url_id} AND cc.agent_id = a.id AND a.platform_id = p.id AND a.browser_id = b.id "
      qs << "GROUP BY b.id ORDER BY total DESC LIMIT 2500"
      set_click_summaries_agents(qs)
    end
  end
  def set_summaries
    case self.url_site
    when SITE_TRIM
      qs  = "SELECT tc.country_id, COUNT(tc.country_id) AS total FROM trim_clicks tc, user_agents ua "
      qs << "WHERE tc.trim_url_id = #{self.url_id} AND tc.agent_id = ua.id AND ua.browser_id != #{UserBrowser::BOT} "
      qs << "GROUP BY country_id ORDER BY total DESC LIMIT 2500"
      set_click_summaries_countries(qs)                                     ## Must go first for @total_clicks

      @clicks_humans = TrimClick.count('tc.id', :from => "trim_clicks tc, user_agents ua",
        :conditions => "tc.agent_id = ua.id AND ua.browser_id != #{UserBrowser::BOT} AND tc.trim_url_id = #{self.url_id}")
      @clicks_bots = TrimClick.count('tc.id', :from => "trim_clicks tc, user_agents ua",
        :conditions => "tc.agent_id = ua.id AND ua.browser_id = #{UserBrowser::BOT} AND tc.trim_url_id = #{self.url_id}")
      @lastvisits = TrimClick.all(:select => "tc.*", :from => "trim_clicks tc, user_agents ua",
        :order => "id DESC", :limit => MAX_HUMAN_CLICKS,
        :conditions => ["tc.agent_id = ua.id AND ua.browser_id != #{UserBrowser::BOT} AND tc.trim_url_id = #{self.url_id}"])                

    when SITE_PICIM
      qs  = "SELECT pc.country_id, COUNT(pc.country_id) AS total FROM picim_clicks pc, user_agents ua "
      qs << "WHERE pc.trim_url_id = #{self.url_id} AND pc.agent_id = ua.id AND ua.browser_id != #{UserBrowser::BOT} "
      qs << "GROUP BY country_id ORDER BY total DESC"
      set_click_summaries_countries(qs)                                     ## Must go first for @total_clicks
    end
  end

  def has_human_clicks?
    return true if @clicks_humans > 0
    return false
  end

  def clicks_countries
    ## RAILS_DEFAULT_LOGGER.info "ALL COUNTRIES: #{@all_countries.to_a.inspect}"
    return @all_countries.to_a
  end
  def clicks_referers
    ## RAILS_DEFAULT_LOGGER.info "ALL REFERERS: #{@all_referers.to_a.inspect}"
    return @all_referers.to_a
  end
  def clicks_browsers
    ## DEFAULT_LOGGER.info "ALL BROWSERS: #{@all_browsers.to_a.inspect}"
    return @all_browsers.to_a
  end
  def clicks_platforms
    ## RAILS_DEFAULT_LOGGER.info "ALL PLATFORMS: #{@all_platforms.to_a.inspect}"
    return @all_platforms.to_a
  end
  
  def length_dates
    return @click_dates_counts.length
  end

  def highest_hours_click_count
    rval = 0
    @click_hours_counts.each {|i| rval = i.to_i if i.to_i > rval }
    return rval
  end
  def highest_dates_click_count
    rval = 0
    @click_dates_counts.each {|i| rval = i.to_i if i.to_i > rval }
    return rval
  end
  def highest_months_click_count
    rval = 0
    @click_months_counts.each {|i| rval = i.to_i if i.to_i > rval }
    return rval
  end
  
  def get_countries_chart(chart_system = TrimPreferences::CHARTS_FLASH, width = 375, height = 110)
    case chart_system
    when TrimPreferences::CHARTS_FLASH
      chart = FlashChartPie.new(:width => width, :height => height,
                                :values => @click_countries_values,
                                :options => { :caption => I18n.translate(:url_title_countries, :scope => :charts) })
    when TrimPreferences::CHARTS_PCHART
      chart = GoogleChartPie.new(:width => width, :height => height,
                                 :title => I18n.translate(:url_title_countries, :scope => :charts))
      chart.set_series(@click_countries_counts)
      chart.set_labels(@click_countries_names)
    end
    set_ss = "[#{width}x#{height}px -> #{@click_countries_counts.join(',')}|#{@click_countries_names.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "URL COUNTRIES Chart SET: #{set_ss} for URL [#{self.url_id}]"
    return chart
  end
  def get_referers_chart(chart_system = TrimPreferences::CHARTS_FLASH, width = 375, height = 110)
    case chart_system
    when TrimPreferences::CHARTS_FLASH
      chart = FlashChartPie.new(:width => width, :height => height,
                                :values => @click_referers_values,
                                :options => { :caption => I18n.translate(:url_title_referers, :scope => :charts) })
    when TrimPreferences::CHARTS_PCHART
      chart = GoogleChartPie.new(:width => width, :height => height,
                                 :title => I18n.translate(:url_title_referers, :scope => :charts))
      chart.set_series(@click_referers_counts)
      chart.set_labels(@click_referers_names)
    end
    set_ss = "[#{width}x#{height}px -> #{@click_referers_counts.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "URL REFERERS Chart SET: #{set_ss} for URL [#{self.url_id}]"
    return chart
  end

  def get_hours_chart(chart_system = TrimPreferences::CHARTS_FLASH, width = 375, height = 110)
    case chart_system
    when TrimPreferences::CHARTS_FLASH
      options = { :caption => I18n.translate(:url_title_clickline, :scope => :charts),
                  :decimals => "0", :adjustDiv => "1",
                  :showValues => "0", :showLabels => "0", :xAxisName => "The First 72 Hours" }
      if self.highest_hours_click_count <= 1
        options.merge!({ :numDivLines => "0", :yAxisMinValue => "0", :yAxisMaxValue => "1" })
      else
        options.merge!({ :numDivLines => get_numdivlines(highest_hours_click_count).to_s })
      end
      chart = FlashChartLine.new(:width => width, :height => height, :values => @click_hours_values, :options => options)

    when TrimPreferences::CHARTS_PCHART
      chart = GoogleChartLine.new(:width => width, :height => height,
                                  :title => I18n.translate(:url_title_clickline, :scope => :charts))
      chart.set_series(@click_hours_counts)
      #chart.set_labels(@click_hours_names)
    end
    set_ss = "[#{width}x#{height}px -> #{@click_hours_counts.join(',')}|#{@click_hours_names.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "URL HOURS TIMELINE Chart SET: #{set_ss} for URL [#{self.url_id}]"
    return chart
  end
  def get_dates_chart(chart_system = TrimPreferences::CHARTS_FLASH, width = 375, height = 110)
    case chart_system
    when TrimPreferences::CHARTS_FLASH
      options = { :caption => I18n.translate(:url_title_clickline, :scope => :charts),
                  :decimals => "0", :adjustDiv => "1", 
                  :showValues => "0", :showLabels => "0",
                  :xAxisName => "Last #{@click_dates_values.length} Days" }
      if self.highest_dates_click_count <= 1
        options.merge!({ :numDivLines => "0", :yAxisMinValue => "0", :yAxisMaxValue => "1" })
      else
        options.merge!({ :numDivLines => get_numdivlines(highest_dates_click_count).to_s })
      end
      if self.length_dates <= MAX_DAYS_BARS
        options.merge!({ :showValues => "1", :showLabels => "1" })
        options.merge!({ :labelDisplay => "Stagger" }) if self.length_dates > 8
        chart = FlashChartBar.new(:width => width, :height => height, :values => @click_dates_values, :options => options)
      else
        chart = FlashChartLine.new(:width => width, :height => height, :values => @click_dates_values, :options => options) end
      
    when TrimPreferences::CHARTS_PCHART
      chart = GoogleChartLine.new(:width => width, :height => height,
                                  :title => I18n.translate(:url_title_clickline, :scope => :charts))
      chart.set_series(@click_dates_counts)
      # chart.set_labels(@click_dates_names)
    end
    set_ss = "[#{width}x#{height}px -> #{@click_dates_counts.join(',')}|#{@click_dates_names.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "URL DATES TIMELINE Chart SET: #{set_ss} for URL [#{self.url_id}]"
    return chart
  end

  def get_months_chart(chart_system = TrimPreferences::CHARTS_FLASH, width = 375, height = 110)
    case chart_system
    when TrimPreferences::CHARTS_FLASH
      options = { :caption => I18n.translate(:url_title_clickline, :scope => :charts),
                  :decimals => "0", :adjustDiv => "1", 
                  :showValues => "1", :showLabels => "1", :xAxisName => "Recent Months" }
      if self.highest_months_click_count <= 1
        options.merge!({ :numDivLines => "0", :yAxisMinValue => "0", :yAxisMaxValue => "1" })
      else
        options.merge!({ :numDivLines => get_numdivlines(highest_months_click_count).to_s })
      end
      chart = FlashChartBar.new(:width => width, :height => height, :values => @click_months_values, :options => options)

    when TrimPreferences::CHARTS_PCHART
      chart = GoogleChartBar.new(:width => width, :height => height, :title => I18n.translate(:url_title_clickline, :scope => :charts))
      chart.set_series(@click_months_counts)
      # chart.set_labels(@click_months_names)
    end
    set_ss = "[#{width}x#{height}px -> #{@click_months_counts.join(',')}|#{@click_months_names.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "URL MONTHS Chart SET: #{set_ss} for URL [#{self.url_id}]"
    return chart
  end
  
  def get_browsers_chart(chart_system = TrimPreferences::CHARTS_FLASH, width = 375, height = 110)
    case chart_system
    when TrimPreferences::CHARTS_FLASH
      chart = FlashChartPie.new(:width => width, :height => height,
                                :values => @click_browsers_values,
                                :options => { :caption => I18n.translate(:url_title_browsers, :scope => :charts) })
    when TrimPreferences::CHARTS_PCHART
      chart = GoogleChartPie.new(:width => width, :height => height,
                                 :title => I18n.translate(:url_title_browsers, :scope => :charts))
      chart.set_series(@click_browsers_counts)
      chart.set_labels(@click_browsers_names)
    end
    set_ss = "[#{width}x#{height}px -> #{@click_browsers_counts.join(',')}|#{@click_browsers_names.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "URL BROWSERS Chart SET: #{set_ss} for URL [#{self.url_id}]"
    return chart
  end  
  def get_platforms_chart(chart_system = TrimPreferences::CHARTS_FLASH, width = 375, height = 110)
    case chart_system
    when TrimPreferences::CHARTS_FLASH
      chart = FlashChartPie.new(:width => width, :height => height,
                                :values => @click_platforms_values,
                                :options => { :caption => I18n.translate(:url_title_platforms, :scope => :charts) })
    when TrimPreferences::CHARTS_PCHART
      chart = GoogleChartPie.new(:width => width, :height => height,
                                 :title => I18n.translate(:url_title_platforms, :scope => :charts))
      chart.set_series(@click_platforms_counts)
      chart.set_labels(@click_platforms_names)
    end
    set_ss = "[#{width}x#{height}px -> #{@click_platforms_counts.join(',')}|#{@click_platforms_names.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "URL PLATFORMS Chart SET: #{set_ss} for URL [#{self.url_id}]"
    return chart
  end
  
  
  protected
  def set_click_summaries_countries(qs)                         ## Returns [names], [counts], [{ name => count }, { name => count }]
    countries = Rails.cache.fetch("countries", :expires_in => 2.hours) { TrimCountry.find(:all) }
    locations = Hash.new
    for cset in ActiveRecord::Base.connection.select_rows(qs)
      cn = countries.find {|i| i.id == cset[0].to_i }.name
      locations.has_key?(cn) ? locations[cn] += cset[1].to_i : locations[cn] = cset[1].to_i
      @total_clicks += cset[1].to_i
      @all_countries << { cn => cset[1].to_i }
    end
    tmp_others_counts, countries_count = 0, 0
    locations.sort {|a,b| b[1] <=> a[1] }.each {|pair|
      if countries_count < COUNTRIES_PER_PIE
        @click_countries_names << pair[0]
        @click_countries_counts << pair[1].to_i
      else tmp_others_counts += pair[1].to_i end
      countries_count += 1
    }
    if countries_count >= COUNTRIES_PER_PIE
      @click_countries_names << I18n.translate(:others, :scope => :reports)
      @click_countries_counts << tmp_others_counts
    end
    @click_countries_names.each_index {|i| @click_countries_values << { @click_countries_names[i] => @click_countries_counts[i] } }
    ## RAILS_DEFAULT_LOGGER.info "Clicks Countries DATA [#{@click_countries_values.inspect}]"
  end
  def set_click_summaries_referers(qs)
    referers = Hash.new
    rs = ActiveRecord::Base.connection.select_rows(qs)
    rs.each do |rset|
      next if rset[0] == nil || rset[0].to_s.length == 0 || rset[1].to_i == 0
      domain = NambuUrl.domain(rset[0])
      if referers.has_key?(domain)
        referers[domain] += rset[1].to_i
      else referers[domain] = rset[1].to_i end
      @all_referers << { rset[0] => rset[1].to_i }
    end
    tmp_others_counts, referers_count = 0, 0
    referers.sort {|a,b| b[1] <=> a[1] }.each {|pair|
      if referers_count < REFERERS_PER_PIE
        @click_referers_names << pair[0]
        @click_referers_counts << pair[1].to_i
      else tmp_others_counts += pair[1].to_i end
      referers_count += 1
    }
    if referers_count >= REFERERS_PER_PIE
      @click_referers_names << I18n.translate(:others, :scope => :reports)
      @click_referers_counts << tmp_others_counts
    end
    @click_referers_names.each_index {|i| @click_referers_values << { @click_referers_names[i] => @click_referers_counts[i] } }
    ## RAILS_DEFAULT_LOGGER.info "Clicks Referers DATA [#{@click_referers_values.inspect}]"
  end

  def set_click_summaries_months(qs)
    rs = ActiveRecord::Base.connection.select_rows(qs)
    23.downto(0) {|i|
      tn = i.months.ago
      if tn.year.to_i > @trim_url.created_at.to_date.year.to_i ||
         (tn.year.to_i >= @trim_url.created_at.to_date.year.to_i && tn.month.to_i >= @trim_url.created_at.to_date.month.to_i)
        dd = false
        rs.each do |rset|
          if rset[0].to_i == tn.to_date.year.to_i && rset[1].to_i == tn.to_date.month.to_i
            @click_months_names  << "#{rset[0]}/#{rset[1]}"
            @click_months_counts << rset[2]
            @click_months_values << { "#{rset[0]}/#{rset[1]}" => rset[2] }
            dd = true
            break
          end
        end
        if not dd
          @click_months_names  << "#{tn.to_date.year}/#{tn.to_date.mon}"
          @click_months_counts << 0
          @click_months_values << { "#{tn.to_date.year}/#{tn.to_date.mon}" => 0 }
        end
      end
    }
    ## RAILS_DEFAULT_LOGGER.info "Clicks Months DATA [#{@click_months_values.inspect}]"
  end  
  def set_click_summaries_dates(qs)
    rs = ActiveRecord::Base.connection.select_rows(qs)
    tn = (DateTime.now).to_date
    74.downto(0) {|i|
      check_date = tn - i
      next if @trim_url.created_at.to_date > check_date
      if rs_date = rs.detect {|rset| rset[0] == check_date.to_s }
        @click_dates_names  << rs_date[0]
        @click_dates_counts << rs_date[1]
        @click_dates_values << { rs_date[0] => rs_date[1] }
      else
        @click_dates_names  << check_date.to_s
        @click_dates_counts << 0
        @click_dates_values << { check_date.to_s => 0 } end
    }
    ## RAILS_DEFAULT_LOGGER.info "Clicks Dates DATA [#{@click_dates_values.inspect}]"
  end
  def set_click_summaries_hours(qs)
    rs = ActiveRecord::Base.connection.select_rows(qs)
    72.downto(1) {|hc|
      tn = hc.hours.ago
      dd = false
      rs.each do |rset|
        if rset[0].to_i == tn.to_date.day && rset[1].to_i == tn.hour
          @click_hours_names  << "#{rset[0]}/#{rset[1]}"
          @click_hours_counts << rset[2]
          @click_hours_values << { "#{rset[0]}/#{rset[1]}" => rset[2] }
          dd = true
          break
        end
      end
      @click_hours_names  << "#{tn.to_date.day}/#{tn.hour}"          if not dd
      @click_hours_counts << 0                                       if not dd
      @click_hours_values << { "#{tn.to_date.day}/#{tn.hour}" => 0 } if not dd
    }
    RAILS_DEFAULT_LOGGER.info "Clicks Last 72H DATA [#{@click_hours_values.inspect}]"
  end

  def set_click_summaries_agents(qs)
    browsers = Rails.cache.fetch("browsers", :expires_in => 1.hours) { UserBrowser.find(:all) }
    platforms = Rails.cache.fetch("platforms", :expires_in => 1.hours) { UserPlatform.find(:all) }
    bsums, psums = Hash.new, Hash.new
    rs = ActiveRecord::Base.connection.select_rows(qs)
    for cset in rs
      b = browsers.find {|i| i.id == cset[1].to_i }.name
      p = platforms.find {|i| i.id == cset[0].to_i }.name
      bsums.has_key?(b) ? bsums[b] += cset[2].to_i : bsums[b] = cset[2].to_i
      psums.has_key?(p) ? psums[p] += cset[2].to_i : psums[p] = cset[2].to_i
      # RAILS_DEFAULT_LOGGER.info "Processed AGENT Result Row: #{cset[0]} -- #{cset[1]} -- #{cset[2]}"
    end
    
    tmp_others_counts, browsers_count = 0, 0
    bsums.sort {|a,b| b[1] <=> a[1] }.each {|pair|
      if browsers_count < BROWSERS_PER_PIE
        @click_browsers_names << pair[0]
        @click_browsers_counts << pair[1].to_i
      else tmp_others_counts += pair[1].to_i end
      browsers_count += 1
      @all_browsers << { pair[0] => pair[1].to_i }
    }
    if browsers_count >= BROWSERS_PER_PIE
      @click_browsers_names << I18n.translate(:others, :scope => :reports)
      @click_browsers_counts << tmp_others_counts
    end
    @click_browsers_names.each_index {|i| @click_browsers_values << { @click_browsers_names[i] => @click_browsers_counts[i] } }
    ## RAILS_DEFAULT_LOGGER.info "Clicks Browsers DATA [#{@click_browsers_values.inspect}]"

    tmp_others_counts, platforms_count = 0, 0
    psums.sort {|a,b| b[1] <=> a[1] }.each {|pair|
      if platforms_count < PLATFORMS_PER_PIE
        @click_platforms_names << pair[0]
        @click_platforms_counts << pair[1].to_i
      else tmp_others_counts += pair[1].to_i end
      platforms_count += 1
      @all_platforms << { pair[0] => pair[1].to_i }
    }
    if platforms_count >= PLATFORMS_PER_PIE
      @click_platforms_names << I18n.translate(:others, :scope => :reports)
      @click_platforms_counts << tmp_others_counts
    end
    @click_platforms_names.each_index {|i| @click_platforms_values << { @click_platforms_names[i] => @click_platforms_counts[i] } }
    ## RAILS_DEFAULT_LOGGER.info "Clicks Platforms DATA [#{@click_platforms_values.inspect}]"
  end
  
  def get_numdivlines(count)
    return 2 if count > 2 && count <= 5
    return 4 if count > 5
    return 1 if count == 2
    return 0
  end
end
