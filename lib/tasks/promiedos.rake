namespace :promiedos do
  task sync: :environment do
    Promiedos::SyncGames.new.call
  end
end