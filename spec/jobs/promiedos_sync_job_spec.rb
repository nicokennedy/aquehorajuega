require "rails_helper"

RSpec.describe PromiedosSyncJob, type: :job do
  it "registra duración, cantidad procesada y último éxito" do
    allow(Promiedos::SyncGames).to receive(:new).and_return(double(call: 7))

    described_class.perform_now("sync")

    run = SynchronizationRun.order(:id).last
    expect(run.status).to eq("succeeded")
    expect(run.processed_games).to eq(7)
    expect(run.duration_ms).to be >= 0
    expect(SynchronizationRun.last_successful_at("sync")).to eq(run.finished_at)
  end

  it "omite una ejecución concurrente cuando el lock está ocupado" do
    connection = ActiveRecord::Base.connection
    allow(connection).to receive(:select_value)
      .with(a_string_including("pg_try_advisory_lock"))
      .and_return(false)
    expect(Promiedos::SyncGames).not_to receive(:new)

    described_class.perform_now("sync")

    run = SynchronizationRun.order(:id).last
    expect(run.status).to eq("skipped")
    expect(run.error_message).to include("Otra sincronización")
  end
end
