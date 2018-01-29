require 'openssl'

class FileEncryptionAdapter
  class ApiError < RuntimeError; end

  attr_reader :cipher_key, :cipher_iv

  def initialize(options = {}, algo = 'AES-256-CBC')
    @uuid = options[:uuid]
    @data = options[:data]
    @cipher_iv = options[:cipher_iv]
    @cipher_key = options[:cipher_key]
    @file_path = note_file_path('.encr')

    cipher_class = OpenSSL::Cipher
    @cipher = cipher_class.new algo if cipher_class.ciphers.include? algo
  end

  def write_to_file!
    File.open(@file_path, 'wb') { |f| f << encrypt_data }

  rescue OpenSSL::Cipher::CipherError, Errno::ENOENT => exc
    raise adapter::ApiError, exc
  end

  def read_from_file!
    File.open(@file_path, 'rb') { |f| decrypt_data(f) }

  rescue OpenSSL::Cipher::CipherError, Errno::ENOENT => exc
    raise adapter::ApiError, exc
  end

  def remove_file!
    File.delete(@file_path) if File.exist?(@file_path)

  rescue Errno::ENOENT => exc
    raise adapter::ApiError, exc
  end

  protected

  def adapter
    self.class
  end

  def encrypt_data
    @cipher.encrypt

    @cipher_iv = @cipher.random_iv
    @cipher_key = @cipher.random_key

    orig_data = @data

    encrypted_data = @cipher.update(orig_data)
    encrypted_data << @cipher.final

    encrypted_data
  end

  def decrypt_data(file)
    @cipher.decrypt
    @cipher.iv = @cipher_iv
    @cipher.key = @cipher_key

    buffer = ''
    decrypted_data = ''

    while file.read(4096, buffer)
      decrypted_data = @cipher.update(buffer)
    end

    decrypted_data << @cipher.final

    decrypted_data
  end

  def note_file_path(ext = '')
    check_notes_directory

    File.expand_path "#{notes_directory}/#{@uuid}#{ext}", __FILE__
  end

  def check_notes_directory
    unless File.directory? notes_directory
      FileUtils.mkdir_p notes_directory
      note_directory_permissions_and_owner
    end
  end

  def note_directory_permissions_and_owner
    FileUtils.chmod 0700, notes_directory
    FileUtils.chown ENV['USER'], nil, notes_directory
  rescue ArgumentError => exc
    raise adapter::ApiError, exc
  end

  def notes_directory
    File.expand_path "../../../#{ENV['NOTES_DIR']}", __FILE__
  end
end