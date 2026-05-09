class ApplicationController < ActionController::Base
  helper SchemaHelper
  before_action :set_locale

  def default_url_options
    { locale: I18n.locale }
  end

  private

  def set_locale
    I18n.locale = params[:locale].presence || :es
  end
end