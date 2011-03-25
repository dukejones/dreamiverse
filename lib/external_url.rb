
class ExternalUrl
  def self.title(url)
    # require 'nokogiri'
    require 'open-uri'
    doc = Nokogiri::HTML(open(url))
    doc.css('head title').text
  end
end

