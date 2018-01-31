class Note < ActiveRecord::Base
  attr_accessor :body_text

  after_initialize :set_default_values
  before_save :save_to_file!, :set_encryption_values
  before_update :save_to_file!, :set_encryption_values
  after_rollback :destroy_saved_file!, on: [:create]
  after_destroy :destroy_saved_file!

  validates :title, :presence => true
  validates :body_text, :presence => true

  has_secure_password

  def verify_password(password)
    verified = authenticate password
    errors.add(:password, 'is invalid') unless verified

    verified
  end

  def protected_body_text
    adapter.read_from_file! unless self.body_text_key.nil?

  rescue adapter.class::ApiError => exc
    logger.error "#{exc.class}: #{exc.message}\n\n#{exc.backtrace.join("\n")}"
    nil
  end

  private

  def save_to_file!
    adapter.write_to_file!

  rescue adapter.class::ApiError => exc
    logger.error "#{exc.class}: #{exc.message}\n\n#{exc.backtrace.join("\n")}"
    nil
  end

  def destroy_saved_file!
    adapter.remove_file!
  end

  def set_default_values
    self.uuid ||= SecureRandom.uuid
  end

  def set_encryption_values
    self.body_text_iv = adapter.cipher_iv
    self.body_text_key = adapter.cipher_key
  end

  def adapter
    @adapter ||= FileEncryptionAdapter.new(adapter_options)
  end

  def adapter_options
    opts = {}
    opts[:uuid] = uuid
    opts[:data] = body_text
    opts[:cipher_iv] = body_text_iv
    opts[:cipher_key] = body_text_key
    opts
  end
end