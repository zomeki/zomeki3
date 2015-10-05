# encoding: utf-8
class Cms::Lib::Navi::Kana

  class << self
    def convert(html, site_id = nil)
      return nil unless Zomeki.config.application['cms.use_kana']

      html = html.to_utf8.gsub(/\r\n/, "\n")
      tmp = mask_html(html)

      bytes = html.unpack("C*")
      texts = []
      pos   = 0

      require 'MeCab'
      mecab_rc = Cms::KanaDictionary.mecab_rc(site_id)
      mc = MeCab::Tagger.new('--node-format=%ps,%pe,%M,%f[7]\n --unk-format= --eos-format= -r ' + mecab_rc)
      mc.parse(tmp).split("\n").each do |line|
        p = line.split(",")
        next if p[0] !~ /^[0-9]+$/
        next if p[2] =~ /^[\*\.]+$/
        next if p[3].blank?
        next if p[2] == p[3]
        next if p[2] !~ /[一-龠]/
        kana = p[3].to_s.tr('ァ-ン', 'ぁ-ん')
        next if p[2] == kana

        s = p[0].to_i
        e = p[1].to_i

        texts << bytes.slice(pos..s-1).pack("C*").force_encoding('utf-8') if pos < s

        word = bytes.slice(s..e-1).pack("C*").force_encoding('utf-8')
        texts << "<ruby><rb>#{word}</rb><rp>(</rp><rt>#{kana}</rt><rp>)</rp></ruby>"

        pos = e
      end

      texts << bytes.slice(pos..-1).pack("C*").force_encoding('utf-8') if pos < bytes.size
      texts.join.html_safe
    end

    private

    def mask_html(html)
      mask = lambda {|s| '*' * s.bytesize }

      tmp = html.gsub(/[\r\n]/, &mask)
      ["head", "style", "script", "ruby"].each do |name|
        tmp.gsub!(/<#{name}[^>]*>.*?<\/#{name}>/im, &mask)
      end
      tmp.gsub!(/<[^>]+>/, &mask)
    end

    # def self.slice(str, start, length)
      # "#{str}".force_encoding('ascii').slice(start, length).to_s.force_encoding('utf-8')
    # end
  end
end
