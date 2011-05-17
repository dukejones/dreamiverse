
class ExternalUrl
  def self.title(url)
    doc = Nokogiri::HTML(open(url))
    doc.css('head title').text
  rescue => e
    nil
  end
end

