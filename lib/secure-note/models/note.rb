class Note < ActiveRecord::Base
  attr_accessor :body_text

  before_create :notes_directory

  has_secure_password

  def save_to_file!
    save!

    @adapter.write_to_file!

  rescue @adapter.class::ApiError => exc
    logger.error "#{exc.class}: #{exc.message}\n\n#{exc.backtrace.join("\n")}"
    nil
  end

  def protected_body_text
    @adapter.read_from_file!

  rescue @adapter.class::ApiError => exc
    logger.error "#{exc.class}: #{exc.message}\n\n#{exc.backtrace.join("\n")}"
    nil
  end

  private

  def notes_directory
    adapter.check_notes_directory
  end

  def adapter
    @adapter ||= FileEncryptionAdapter.new(note_uuid, body_text)
  end

  def note_uuid
    self.id
  end
end