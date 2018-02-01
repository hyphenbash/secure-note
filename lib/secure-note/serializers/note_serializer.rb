class NoteSerializer < ActiveModel::Serializer
  attributes :uuid,
             :title,
             :body_text

  def body_text
    object.protected_body_text
  end
end