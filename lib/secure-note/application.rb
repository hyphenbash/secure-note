require 'dotenv/load'
require 'securerandom'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra-active-model-serializers'
require 'sinatra/activerecord'
require 'sinatra/bootstrap'
require 'slim'

module SecureNote
  class Application < Sinatra::Base
    use Rack::MethodOverride

    register Sinatra::ActiveRecordExtension
    register Sinatra::Contrib
    register Sinatra::Bootstrap::Assets

    set :database_file, File.expand_path('../../../config/database.yml', __FILE__)
    set :views, File.expand_path('../views', __FILE__)
    set :serializers_path, File.expand_path('../serializers', __FILE__)

    set :active_model_serializers, { root: false }

    enable :sessions

    configure :development, :test do
      enable :logging
    end

    before '/secure-notes/:uuid' do
      set_note
    end

    before '/secure-notes/:uuid/*' do
      set_note
    end

    after '/secure-notes/:uuid/*' do
      session[:notice] = nil
    end

    get '/secure-notes' do
      @notes = Note.all
      notice = session[:notice]
      session[:notice] = nil

      slim :index, :locals => { notice: notice }
    end

    get '/secure-notes/new' do
      @note = Note.new
      slim :new
    end

    get '/secure-notes/:uuid/view' do
      slim :get_note_form, :locals => { action: 'view', notice: session[:notice] }
    end

    post '/secure-notes/:uuid/view' do
      respond_to do |f|
        if @note && @note.verify_password(note_params[:password])
          f.html { status :ok; slim :note }
          f.json { status :ok; json @note }
        else
          f.html { status :unauthorized; slim :get_note_form, :locals => { action: 'view', notice: session[:notice] } }
          f.json { status :unauthorized; json messages: @note.errors.to_a }
        end
      end
    end

    get '/secure-notes/:uuid/edit' do
      slim :get_note_form, :locals => { action: 'edit', notice: session[:notice] }
    end

    post '/secure-notes/:uuid/edit' do
      respond_to do |f|
        if @note && @note.verify_password(note_params[:password])
          f.html { status :ok; slim :edit }
          f.json { status :ok; json @note }
        else
          f.html { status :unauthorized; slim :get_note_form, :locals => { action: 'edit', notice: session[:notice] } }
          f.json { status :unauthorized; json messages: @note.errors.to_a }
        end
      end
    end

    get '/secure-notes/:uuid/remove' do
      slim :get_note_form, :locals => { action: 'remove', notice: session[:notice] }
    end

    post '/secure-notes/:uuid/remove' do
      respond_to do |f|
        if @note && @note.verify_password(note_params[:password])
          f.html { status :ok; slim :remove }
          f.json { status :ok; json @note }
        else
          f.html { status :unauthorized; slim :get_note_form, :locals => { action: 'remove', notice: session[:notice] } }
          f.json { status :unauthorized; json messages: @note.errors.to_a }
        end
      end
    end

    post '/secure-notes' do
      @note = Note.new(note_params)

      respond_to do |f|
        if @note.save
          session[:notice] = "Note #{@note.title} was successfully created."

          f.html { status :created; redirect note_view_path }
          f.json { status :created; json message: session[:notice] }
        else
          f.html { status :bad_request; slim :new }
          f.json { status :bad_request; json messages: @note.errors.to_a }
        end
      end
    end

    patch '/secure-notes/:uuid' do
      respond_to do |f|
        if @note.update(note_params)
          session[:notice] = "Note #{@note.title} was successfully updated."

          f.html { status :ok; redirect note_view_path }
          f.json { status :ok; json message: session[:notice] }
        else
          f.html { status :bad_request; slim :edit }
          f.json { status :bad_request; json messages: @note.errors.to_a }
        end
      end
    end

    delete '/secure-notes/:uuid' do
      respond_to do |f|
        if @note.destroy
          session[:notice] = "Note #{@note.title} was successfully removed."

          f.html { status :ok; redirect index_path }
          f.json { status :ok; json message: session[:notice] }
        else
          f.html { status :bad_request; slim :remove }
          f.json { status :bad_request; json messages: @note.errors.to_a }
        end
      end
    end

    private

    def set_note
      @note = Note.find_by(uuid: params[:uuid])
    end

    def permit_params(*permitted_params)
      parameters = begin JSON.parse(request.body.read) rescue params end.symbolize_keys

      parameters.select { |param| permitted_params.include? param.to_sym }
    end

    def note_params
      permit_params(
          :uuid,
          :title,
          :body_text,
          :password
      )
    end

    def index_path
      '/secure-notes'
    end

    def note_view_path
      "/secure-notes/#{@note.uuid}/view"
    end
  end
end
