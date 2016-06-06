require 'openssl'
class Util::String::Crypt
  def self.encrypt(msg, pass = 'phrase', salt = nil)
    enc  = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    enc.encrypt
    enc.pkcs5_keyivgen(pass, salt)
    Base64.encode64(enc.update(msg) + enc.final).encode(Encoding::UTF_8)
  rescue
    false
  end

  def self.decrypt(msg, pass = 'phrase', salt = nil)
    dec = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    dec.decrypt
    dec.pkcs5_keyivgen(pass, salt)
    dec.update(Base64.decode64(msg.encode(Encoding::ASCII_8BIT))) + dec.final
  rescue
    false
  end
end
