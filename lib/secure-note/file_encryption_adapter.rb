require 'openssl'

class FileEncryptionAdapter
  class ApiError < RuntimeError; end

  def initialize(uuid, body_text)
    @uuid = uuid
    @body_text = body_text
    # @key = nil
    # @iv = nil
  end

  def write_to_file!
    encrypted_text = encrypted

    File.open(note_file_path('.encr'), 'wb') { |f| f << encrypted_text }

  rescue OpenSSL::Cipher::CipherError, Errno::ENOENT => exc
    raise adapter::ApiError, exc
  end

  def read_from_file!
    buffer = ''

    File.open(note_file_path('.encr'), 'rb') { |f| f << decrypted_text(f, buffer) }

  rescue OpenSSL::Cipher::CipherError, Errno::ENOENT => exc
    raise adapter::ApiError, exc
  end

  def check_notes_directory
    FileUtils.mkdir_p(notes_directory) unless File.directory?(notes_directory)
  end

  private

  def adapter
    self.class
  end

  def encrypted
    cipher.encrypt
    set_key_iv(cipher.random_key, cipher.random_iv)

    encrypted_text = cipher.update(@body_text)

    encrypted_text << cipher.final
  end

  def decrypted(file, buffer)
    cipher.decrypt
    cipher.key = @key
    cipher.iv = @iv

    while file.read(4096, buffer)
      file << cipher.update(buffer)
    end
    file << cipher.final

    decrypted_text = cipher.update(buffer)
    cipher.final

    decrypted_text
  end

  def set_key_iv(key, iv)
    @key = key
    @iv = iv
  end

  def cipher
    OpenSSL::Cipher.new('AES-128-CBC')
  end

  def note_file_path(ext = '')
    File.expand_path "#{notes_directory}/#{@uuid}#{ext}", __FILE__
  end

  def notes_directory
    File.expand_path "../../../#{ENV['NOTES_DIR']}", __FILE__
  end
end