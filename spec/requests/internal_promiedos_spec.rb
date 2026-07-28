require "rails_helper"

RSpec.describe "Internal Promiedos sync", type: :request do
  around do |example|
    previous = ENV["PROMIEDOS_SYNC_TOKEN"]
    ENV["PROMIEDOS_SYNC_TOKEN"] = "secret"
    ActiveJob::Base.queue_adapter = :test
    example.run
  ensure
    previous.nil? ? ENV.delete("PROMIEDOS_SYNC_TOKEN") : ENV["PROMIEDOS_SYNC_TOKEN"] = previous
  end

  it "encola el sync normal y responde 202" do
    expect {
      post "/internal/promiedos/sync", params: { token: "secret" }
    }.to have_enqueued_job(PromiedosSyncJob).with("sync")

    expect(response).to have_http_status(:accepted)
  end

  it "encola el full sync sin crear threads dentro del request" do
    expect {
      post "/internal/promiedos/full_sync", params: { token: "secret" }
    }.to have_enqueued_job(PromiedosSyncJob).with("full_sync")

    expect(response).to have_http_status(:accepted)
  end

  it "rechaza tokens inválidos" do
    post "/internal/promiedos/sync", params: { token: "wrong" }

    expect(response).to have_http_status(:unauthorized)
  end
end
