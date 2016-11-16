
class PdfGenerator
  def initialize(url:, cookies:)
    @options = {
      T: 0, B: 0, L: 0, R: 0, # margins
      s: 'Letter',

    }
  end

  def save(filename)
    dir = Rails.public_path.join('pdfs')
    file_path = File.join(dir, "#{filename}.pdf")
    output = `#{command}`
    Rails.logger.info output
    file_path
  end

  def command
    puts shelloptions(options)
    [wkhtmltopdf, shelloptions(@options), shellcookies(@cookies)].join(' ')
  end

  def shelloptions(options)
    options.map do |option, value|
      "-#{option} #{value}"
    end.shelljoin
  end

  def shellcookies(cookies)
    cookies.each do |name, value|
      "--cookie #{name} #{value}"
    end.shelljoin
  end

  def wkhtmltopdf
    @wkhtmltopdf ||= `which wkhtmltopdf`
    raise 'no binary wkhtmltopdf' unless @wkhtmltopdf
    @wkhtmltopdf
  end
end
