class ApplicationController < ActionController::Base
  helper SchemaHelper
  before_action :redirect_to_canonical_host
  before_action :redirect_to_spanish_locale
  before_action :set_locale

  def default_url_options
    { locale: I18n.locale, host: Site::HOST, protocol: "https" }
  end

  private

  def redirect_to_canonical_host
    return unless request.host.casecmp?("www.#{Site::HOST}")

    redirect_to "#{Site::URL}#{request.fullpath}", status: :moved_permanently,
      allow_other_host: true
  end

  def redirect_to_spanish_locale
    return if params[:locale].present?
    return if controller_path.start_with?("internal/")

    localized_path = request.path == "/" ? "/es" : "/es#{request.path}"
    redirect_to "#{Site::URL}#{localized_path}#{request.query_string.present? ? "?#{request.query_string}" : ""}",
      status: :moved_permanently,
      allow_other_host: true
  end

  def set_locale
    I18n.locale = params[:locale].presence || :es
  end
end
