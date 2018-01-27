module FormHelpers
  def fill_post_note_form(params)
    fill_in 'title', with: params[:title]
    fill_in 'body_text', with: params[:body_text]
    fill_in 'password', with: params[:password]

    click_button 'Submit'
  end

  def fill_in_get_note_form(params)
    fill_in 'password', with: params[:password]

    click_button 'Submit'
  end
end