class Note < ActiveRecord::Base
  attr_accessor :body_text

  before_create :check_notes_directory

  has_secure_password

  def save_to_file!
    save!
    write_to_file!
  end

  def protected_body_text
    read_from_file!
  end


  private

  def write_to_file!
    File.open(note_file_path, 'w') { |f| f.write body_text }

  rescue Errno::ENOENT => exc
    logger.error "#{exc.class}: #{exc.message}\n\n#{exc.backtrace.join("\n")}"
    nil
  end

  def read_from_file!
    File.open(note_file_path, 'r') { |f| f.read body_text }

  rescue Errno::ENOENT => exc
    logger.error "#{exc.class}: #{exc.message}\n\n#{exc.backtrace.join("\n")}"
    nil
  end

  def check_notes_directory
    FileUtils.mkdir_p notes_directory unless File.directory? notes_directory
  end

  def note_file_path
    File.expand_path "#{notes_directory}/#{self.id}.txt", __FILE__
  end

  def notes_directory
    File.expand_path "../../../../#{ENV['NOTES_DIR']}", __FILE__
  end
end