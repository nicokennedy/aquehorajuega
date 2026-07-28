class PromiedosSyncJob < ApplicationJob
  queue_as :default

  LOCK_NAME = "aquehorajuega:promiedos_sync"
  SERVICES = {
    "sync" => Promiedos::SyncGames,
    "sync_live" => Promiedos::LiveSyncGames,
    "full_sync" => Promiedos::FullSyncGames
  }.freeze

  def perform(kind)
    service_class = SERVICES.fetch(kind)
    run = SynchronizationRun.create!(
      kind: kind,
      status: "running",
      started_at: Time.current
    )

    unless acquire_lock
      finish_run(run, status: "skipped", error_message: "Otra sincronización está en curso")
      Rails.logger.warn("[PromiedosSyncJob] #{kind} omitida: lock ocupado")
      return
    end

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Rails.logger.info("[PromiedosSyncJob] #{kind} iniciada run_id=#{run.id}")

    processed_games = service_class.new.call.to_i
    duration_ms = elapsed_ms(started)
    finish_run(run, status: "succeeded", processed_games: processed_games, duration_ms: duration_ms)
    Rails.logger.info(
      "[PromiedosSyncJob] #{kind} finalizada run_id=#{run.id} " \
      "duration_ms=#{duration_ms} processed_games=#{processed_games}"
    )
  rescue => error
    duration_ms = started ? elapsed_ms(started) : nil
    finish_run(run, status: "failed", duration_ms: duration_ms, error_message: error.message) if run
    Rails.logger.error(
      "[PromiedosSyncJob] #{kind} falló run_id=#{run&.id} " \
      "duration_ms=#{duration_ms} error=#{error.class}: #{error.message}"
    )
    raise
  ensure
    release_lock if @lock_acquired
  end

  private

  def acquire_lock
    @lock_acquired = ActiveRecord::Base.connection.select_value(
      "SELECT pg_try_advisory_lock(hashtext(#{ActiveRecord::Base.connection.quote(LOCK_NAME)}))"
    )
    ActiveModel::Type::Boolean.new.cast(@lock_acquired)
  end

  def release_lock
    ActiveRecord::Base.connection.select_value(
      "SELECT pg_advisory_unlock(hashtext(#{ActiveRecord::Base.connection.quote(LOCK_NAME)}))"
    )
  end

  def elapsed_ms(started)
    ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
  end

  def finish_run(run, **attributes)
    run.update!(attributes.merge(finished_at: Time.current))
  end
end
