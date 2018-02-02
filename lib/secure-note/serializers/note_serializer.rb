class NoteSerializer < ActiveModel::Serializer
  attributes :uuid,
             :title,
             :body_text

  def body_text
    unless object.body_text.nil?
      object.protected_body_text
    else
      "[PROTECTED]"
    end
  end
end