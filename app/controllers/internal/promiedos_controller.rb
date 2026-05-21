module Internal
  class PromiedosController < ApplicationController
    skip_before_action :verify_authenticity_token

    def sync
      unless params[:token] == ENV["PROMIEDOS_SYNC_TOKEN"]
        return head :unauthorized
      end

      Promiedos::SyncGames.new.call

      render plain: "ok"
    end
  end
end