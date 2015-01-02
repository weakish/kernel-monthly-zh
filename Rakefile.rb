# by Jakukyo Friel <weakish@gmail.com> (http://weakish.github.io)
# under MIT

require 'ampex'
require 'nokogiri'
require 'json'
require 'open-uri'

task :fetch do
  def parse_links(url)
    yearly = Nokogiri::HTML open(url)
    links = yearly.css('#bodyContent  a').map &X['href']
    links.reject! &X.include?('#')
    links.select! &X.match(/20[0-9][0-9]-[0-9]+$/)
    titles = links.map &X.gsub(/^\/index\.php\//, '')
  end
  def fetch_one(title)
    api_url = "http://kernel.taobao.org/api.php?format=json&action=query&titles=#{title}&prop=revisions&rvprop=content"
    json = JSON.parse open(api_url).read
    page_id = json['query']['pages'].keys[0]
    json['query']['pages'][page_id]["revisions"][0]["*"]
  end
  previous_years = 2010 .. (Time.now.year - 1)
  previous_years_links = previous_years.map do |year|
    "http://kernel.taobao.org/index.php/#{URI::encode('内核月报') + year.to_s}"
  end
  current_year_link = 'http://kernel.taobao.org/index.php/Monthly_Kernel_Reports'
  index_links = previous_years_links << current_year_link
  index_links.each do |index|
    titles = parse_links(index)
    titles.each do |title|
      content = fetch_one(title)
      open("wiki/#{title.match(/201[0-9]-[0-9]+$/).to_s}.wiki", 'w') do |f|
        f.puts content
      end
    end
  end
end

task :update do
  puts 'Not implemented yet.'
  puts 'Please send pull requests. Thanks.'
end
