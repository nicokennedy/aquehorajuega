namespace :promiedos do
  task sync: :environment do
    Promiedos::SyncGames.new.call
  end

  task full_sync: :environment do
    Promiedos::FullSyncGames.new.call
  end
end