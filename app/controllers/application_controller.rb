class ApplicationController < ActionController::Base
  helper SchemaHelper
  before_action :redirect_to_canonical
  before_action :set_locale

  def default_url_options
    { locale: I18n.locale }
  end

  private

  def redirect_to_canonical
    if request.path != "/" && request.path.end_with?("/")
      redirect_to request.path.chomp("/"), status: :moved_permanently
    end
  end

  def set_locale
    I18n.locale = params[:locale].presence || :es
  end
end