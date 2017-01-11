require 'csv'
class Util::String::CsvToHtml
  class << self
    def convert(csv)
      return '' if csv.blank?

      rows = CSV.parse(csv)
      if rows.empty?
        ''
      else
        thead = "<thead><tr><th>#{rows.shift.join('</th><th>')}</th></tr></thead>"
        trs = rows.map{|r| "<tr><td>#{r.join('</td><td>')}</td></tr>" }
        tbody = "<tbody>#{trs.join}</tbody>"
        "<table>#{thead}#{tbody}</table>"
      end
    end
  end
end
