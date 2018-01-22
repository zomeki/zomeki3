class Util::Image
  class << self
    def reduced_size(src_width, src_height, dst_width, dst_height)
      src_w  = src_width.to_f
      src_h  = src_height.to_f
      dst_w  = dst_width.to_f
      dst_h  = dst_height.to_f
      src_r  = (src_w / src_h)
      dst_r  = (dst_w / dst_h)

      if !src_r.nan? && !dst_r.nan?
        if dst_r > src_r
          dst_w = (dst_h * src_r)
        else
          dst_h = (dst_w / src_r)
        end
      end

      return dst_w.ceil, dst_h.ceil
    end
  end
end
