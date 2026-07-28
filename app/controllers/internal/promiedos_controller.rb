module Internal
  class PromiedosController < ApplicationController
    skip_before_action :verify_authenticity_token

    def sync
      unless params[:token] == ENV["PROMIEDOS_SYNC_TOKEN"]
        return head :unauthorized
      end

      PromiedosSyncJob.perform_later("sync")
      render plain: "queued", status: :accepted
    end

    def sync_live
      unless params[:token] == ENV["PROMIEDOS_SYNC_TOKEN"]
        return head :unauthorized
      end

      PromiedosSyncJob.perform_later("sync_live")
      render plain: "queued", status: :accepted
    end

    def full_sync
      unless params[:token] == ENV["PROMIEDOS_SYNC_TOKEN"]
        return head :unauthorized
      end

      PromiedosSyncJob.perform_later("full_sync")
      render plain: "queued", status: :accepted
    end
  end
end
