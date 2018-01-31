class Cms::Lib::Navi::Kana

  class << self
    def convert(html, site_id = nil)
      html = html.to_utf8.gsub(/\r\n/, "\n")
      tmp = mask_html(html)

      texts = []
      pos   = 0

      parse_by_mecab(tmp, site_id).split("\n").each do |line|
        s, e, word, kana = line.split(",")
        next if s !~ /^[0-9]+$/
        next if kana.blank?

        s = s.to_i
        e = e.to_i
        kana = kana.to_s.tr('ァ-ン', 'ぁ-ん')
        roman = Romaji.kana2romaji(kana)

        texts << html.byteslice(pos..s-1) if pos < s

        ruby = %Q|<ruby><rb>#{word}</rb><rp>(</rp>|
        ruby << %Q|<rt class="kana">#{kana}</rt>| if word =~ /[一-龠々]/
        ruby << %Q|<rt class="roman" style="display: none;">#{roman}</rt><rp>)</rp></ruby>|
        texts << ruby

        pos = e
      end

      texts << html.byteslice(pos..-1) if pos < html.bytesize
      texts.join.html_safe
    end

    private

    def mask_html(html)
      mask = lambda {|s| '*' * s.bytesize }

      tmp = html.gsub(/[\r\n]/, &mask)
      ["head", "style", "script", "ruby"].each do |name|
        tmp.gsub!(/<#{name}[^>]*>.*?<\/#{name}>/im, &mask)
      end
      tmp.gsub(/<[^>]+>/, &mask)
    end

    def parse_by_mecab(text, site_id)
      require 'MeCab'
      mecab_rc = Cms::KanaDictionary.mecab_rc(site_id)
      mc = MeCab::Tagger.new('--node-format=%ps,%pe,%m,%f[7]\n --unk-format= --eos-format= -r ' + mecab_rc)
      mc.parse(text).to_s
    rescue => e
      error_log e
      ''
    end
  end
end
