##
# Copyright (c) The Nambu Network Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##

require 'trim_country'
require 'url_destination'
require 'url_shortening'

class TrimsList
  attr_reader :user_id, :session_id, :all_trims, :trims, :ids, :counts, :urls_start, :urls_needed, :sort_option, :search_tags
  attr_reader :clicks_summary_chart, :countries_summary_chart
  attr_reader :clicks_summary_float, :countries_summary_float

  MAX_URLS_IN_LIST = 35
  MAX_URLS_IN_TOTAL = 250
  DEFAULT_URLS_IN_LIST = 10

  def initialize(hash = Hash.new)
    hash.each do |key, value|
      self.instance_variable_set("@#{key}", value)
      self.class.send(:define_method, key, proc{ self.instance_variable_get("@#{key}") })
      self.class.send(:define_method, "#{key}=", proc{|value| self.instance_variable_set("@#{key}", value) })
    end
    @user_id ||= nil
    @session_id ||= nil
    @urls_start ||= 0 
    @urls_needed ||= DEFAULT_URLS_IN_LIST
    @sort_option ||= TrimUrl::URLSORT_TRIMMED
    @search_tags ||= Array.new
    @all_trims, @trims, @ids, @counts = Array.new, Array.new, Array.new, Array.new

    set_trims

    @clicks_summary_chart, @countries_summary_chart = nil, nil
    @clicks_summary_float, @countries_summary_float = "none", "none"
  end
  
  def length
    @trims.length
  end
  def empty?
    @trims.empty?
  end
  
  def clear
    @all_trims, @trims, @ids, @counts = Array.new, Array.new, Array.new, Array.new
  end
  def reload(user_id = nil, session_id = nil, sort_option = TrimUrl::URLSORT_TRIMMED)
    @user_id = user_id.to_i if user_id
    @session_id = session_id if session_id
    @sort_option = sort_option.to_i
    set_trims
  end

  def url_clicks(trim_url_id)
    return @counts[@ids.index(trim_url_id)] if @ids.include?(trim_url_id)
    return 0
  end
  def urls_labels
    tmpa = Array.new
    @trims.each_index {|i| tmpa << @trims[i].shortening.surl }
    return tmpa
  end
  def urls_counts
    tmpa = Array.new
    @trims.each_index {|i| tmpa << @counts[i] }
    return tmpa
  end
  def urls_as_labeled_hash
    tmpa = Array.new
    @trims.each_index {|i| tmpa << { @trims[i].shortening.surl => @counts[i] } }
    return tmpa
  end
  def urls_highest_click_count
    rval = 0
    @counts.each {|i| rval = i.to_i if i.to_i > rval }
    return rval
  end
  
  def has_clicks?
    @counts.each {|i| return true if i > 0 } if @counts && (not @counts.empty?)
    return false
  end
  def has_trims?
    (not self.empty?)
  end
  def has_account_trims?
    return true if TrimUserUrl.exists?({ :user_id => self.user_id }) if self.user_id
    return false
  end
  def has_session_trims?
    return true if TrimSessionUrl.exists?({ :session_id => self.session_id }) if self.session_id
    return false
  end

  def trim_belongs_to_account?(trim_url_id)
    return true if TrimUserUrl.exists?({ :user_id => self.user_id, :trim_url_id => trim_url_id }) if self.user_id
    return false
  end
  def trim_belongs_to_session?(trim_url_id)
    return true if TrimSessionUrl.exists?({ :session_id => self.session_id, :trim_url_id => trim_url_id }) if self.session_id
    return false
  end

  def set_charts(chart_system = TrimPreferences::CHARTS_FLASH, maximum_width = 930)
    if self.has_trims? && self.has_clicks?
      set_urlchart_clicks(chart_system, maximum_width)
      set_urlchart_countries(chart_system, maximum_width)
    end
  end

  protected
  def set_trims
    self.clear
    if has_session_trims?
      case self.sort_option
      when TrimUrl::URLSORT_VISITS
        @all_trims = TrimUrl.all(:select => "tu.*", :from => "trim_urls tu, trim_session_urls tsu",
                                 :order => "tu.clicks DESC",
                                 :conditions => ["tu.id = tsu.trim_url_id AND tsu.session_id = '#{self.session_id}'"], :limit => MAX_URLS_IN_TOTAL)

      when TrimUrl::URLSORT_DESTINATION
        @all_trims = TrimUrl.all(:select => "tu.*",
          :from => "trim_session_urls tsu, trim_urls tu, url_shortenings surls, url_destinations dests",
          :order => "dests.url",
          :limit => MAX_URLS_IN_TOTAL,
          :conditions =>
            ["tsu.session_id = '#{self.session_id}' AND tsu.trim_url_id = tu.id AND tu.shortened_id = surls.id AND surls.url_id = dests.id"])

      else
        @all_trims = TrimUrl.all(:select => "tu.*", :from => "trim_urls tu, trim_session_urls tsu",
                                 :conditions => ["tu.id = tsu.trim_url_id AND tsu.session_id = '#{self.session_id}'"],
                                 :order => "tu.id DESC", :limit => MAX_URLS_IN_TOTAL)
      end
      set_ids_counts
    end

    if has_account_trims?
      case self.sort_option
      when TrimUrl::URLSORT_VISITS
        @all_trims = TrimUrl.all(:select => "tu.*", :from => "trim_urls tu, trim_user_urls tuu",
                                 :order => "tu.clicks DESC",
                                 :conditions => ["tu.id = tuu.trim_url_id AND tuu.user_id = #{self.user_id}"], :limit => MAX_URLS_IN_TOTAL)

      when TrimUrl::URLSORT_DESTINATION
        @all_trims = TrimUrl.all(:select => "tu.*",
          :from => "trim_user_urls tuu, trim_urls tu, url_shortenings surls, url_destinations dests",
          :order => "dests.url",
          :limit => MAX_URLS_IN_TOTAL,
          :conditions =>
            ["tuu.user_id = #{self.user_id} AND tuu.trim_url_id = tu.id AND tu.shortened_id = surls.id AND surls.url_id = dests.id"])

      else
        @all_trims = TrimUrl.all(:select => "tu.*", :from => "trim_urls tu, trim_user_urls tuu",
                                 :conditions => ["tu.id = tuu.trim_url_id AND tuu.user_id = #{self.user_id}"],
                                 :order => "tu.id DESC", :limit => MAX_URLS_IN_TOTAL)
      end
      set_ids_counts
    end
    process_search_tags if not @search_tags.empty?
  end
  def set_ids_counts
    @trims = @all_trims[self.urls_start, self.urls_needed]
    @ids = @trims.collect {|tu| tu.id }
    @counts = @trims.collect {|tu| tu.clicks_count }
  end
  def process_search_tags
    strims = Array.new
    @search_tags.each do |tag|
      @trims.each do |trim_url|
        if trim_url.shortening.url_destination.url.include?(tag)
          strims << trim_url
        elsif trim_url.description && trim_url.description.include?(tag)
          strims << trim_url
        elsif trim_url.title && trim_url.title.include?(tag)
          strims << trim_url
        elsif trim_url.searchtags && trim_url.searchtags.include?(tag)
          strims << trim_url end
      end
    end
    @trims = strims
    @all_trims = @trims
  end

  def set_urlchart_clicks(chart_system, maximum_width)
    ## The clicks comparison chart if a bar chart of total visits per tr.im URL within the data set.
    ## It has 2 set widths based on the number of URLs within the data set:
    ##   0 >= 5 => 300px  ||  >5 => 600px  ||   >10 => 800px

    clicks_summary_width, clicks_summary_height, @clicks_summary_float = 300, WEBSITE_CONFIG['chart_height_clicks'], "right"
    clicks_summary_width, @clicks_summary_float = 600, "none" if counts.length > 5
    clicks_summary_width, clicks_summary_height, @clicks_summary_float = 800, clicks_summary_height + 50, "none" if counts.length > 10
    clicks_summary_width = maximum_width if clicks_summary_width > maximum_width

    case chart_system
    when TrimPreferences::CHARTS_FLASH
      links, tips = Array.new, Array.new
      @trims.each_index {|i|
        links << ERB::Util::h("/statistics/#{@trims[i].shortening.surl}")
        tips  << ERB::Util::h(@trims[i].shortening.url_destination.url)
      }
      options = { :adjustDiv => "1", :decimals => "0",
                  :labelDisplay => 'Rotate', :slantLabels => '1',
                  :caption => I18n.translate(:summary_visits, :scope => :charts) }
      if self.urls_highest_click_count <= 1
        options.merge!({ :numDivLines => "0", :yAxisMinValue => "0", :yAxisMaxValue => "1" })
      else
        options.merge!({ :numDivLines => get_numdivlines(urls_highest_click_count).to_s })
      end
      @clicks_summary_chart = FlashChartBar.new(:width => clicks_summary_width, :height => clicks_summary_height,
                                                :values => self.urls_as_labeled_hash,
                                                :links => links,
                                                :tool_texts => tips, :options => options)
    when TrimPreferences::CHARTS_PCHART
      @clicks_summary_chart = GoogleChartBar.new(:width => clicks_summary_width, :height => clicks_summary_height,
                                                 :title => I18n.translate(:summary_visits, :scope => :charts))
      @clicks_summary_chart.set_series(self.urls_counts)
      @clicks_summary_chart.set_labels(self.urls_labels)
    end
    RAILS_DEFAULT_LOGGER.info "CLICKS Chart SET: [#{clicks_summary_width} -> #{self.counts.join(',')}] FOR [#{self.counts.length} URLs]"
  end
  def set_urlchart_countries(chart_system, maximum_width)
    countries = Rails.cache.fetch("countries") { TrimCountry.find(:all) }
    locations = Hash.new
    tmp_others_counts, countries_count = 0, 0
    qs  = "SELECT country_id, COUNT(country_id) AS cc FROM trim_clicks "
    qs << "WHERE trim_url_id IN (#{self.ids.join(',')}) GROUP BY country_id ORDER BY cc DESC"
    for cset in ActiveRecord::Base.connection.select_rows(qs)
      cn = countries.find {|i| i.id == cset[0].to_i }.name
      locations.has_key?(cn) ? locations[cn] += cset[1].to_i : locations[cn] = cset[1].to_i
    end

    max_countries  = WEBSITE_CONFIG['chart_countries_per_pie']
    max_countries += 2 if maximum_width > 500 && ids.length > 10
    
    click_locations_names, click_locations_counts, click_locations_values = Array.new, Array.new, Array.new
    locations.sort {|a,b| b[1] <=> a[1] }.each {|pair|
      if countries_count < max_countries
        click_locations_names  << pair[0]
        click_locations_counts << pair[1].to_i
      else tmp_others_counts += pair[1].to_i end
      countries_count += 1
    }
    if countries_count >= max_countries
      click_locations_names  << "Others"
      click_locations_counts << tmp_others_counts
    end

    countries_summary_height, countries_summary_width, @countries_summary_float = WEBSITE_CONFIG['chart_height_countries'], 400, "left"
    countries_summary_width, @countries_summary_float = 600, "none" if ids.length > 5
    countries_summary_height, countries_summary_width, @countries_summary_float = countries_summary_height + 50, 800, "none" if ids.length > 10
    countries_summary_width = maximum_width if countries_summary_width > maximum_width

    case chart_system
    when TrimPreferences::CHARTS_FLASH
      click_locations_names.each_index {|i| click_locations_values << { click_locations_names[i] => click_locations_counts[i] } }
      @countries_summary_chart = FlashChartPie.new(:width => countries_summary_width, :height => countries_summary_height,
                                                   :values => click_locations_values,
                                                   :options => { :caption => I18n.translate(:summary_countries, :scope => :charts) })
    when TrimPreferences::CHARTS_PCHART
      @countries_summary_chart = GoogleChartPie.new(:width => countries_summary_width, :height => countries_summary_height,
                                                    :title => I18n.translate(:summary_countries, :scope => :charts))
      click_locations_names.each_index {|i| 
        @countries_summary_chart.append_data(click_locations_counts[i])
        @countries_summary_chart.append_label(click_locations_names[i])
      }
    end
    set_ss = "[#{countries_summary_width} -> #{click_locations_counts.join(',')}|#{click_locations_names.join(',')}]"
    RAILS_DEFAULT_LOGGER.info "COUNTRIES Chart SET: #{set_ss} FOR [#{self.ids.length} URLs]"
  end
  
  def get_numdivlines(count)
    return 2 if count > 2 && count <= 5
    return 4 if count > 5
    return 1 if count == 2
    return 0
  end
end
