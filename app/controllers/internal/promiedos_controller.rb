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

    def full_sync
      unless params[:token] == ENV["PROMIEDOS_SYNC_TOKEN"]
        return head :unauthorized
      end

      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          Promiedos::FullSyncGames.new.call
        end
      end

      render plain: "ok"
    end
  end
end