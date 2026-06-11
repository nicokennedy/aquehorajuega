Rails.application.routes.draw do
  get "/sitemap.xml", to: redirect("/sitemap.xml.gz")

  get 'dates/show'
  get 'teams/show'

  post "/internal/promiedos/sync", to: "internal/promiedos#sync"
  get "/internal/promiedos/sync", to: "internal/promiedos#sync"
  post "/internal/promiedos/sync_live", to: "internal/promiedos#sync_live"
  get "/internal/promiedos/sync_live", to: "internal/promiedos#sync_live"
  post "/internal/promiedos/full_sync", to: "internal/promiedos#full_sync"
  get "/internal/promiedos/full_sync", to: "internal/promiedos#full_sync"

  scope "(:locale)", locale: /es|en|pt/ do
    root "games#index"

    get "/partidos-de-hoy", to: "games#today", as: :today_games_page
    get "/proximos-partidos", to: "games#upcoming", as: :upcoming_games_page

    get "/:competition/groups", to: "games#groups", as: :competition_groups
    get "/:competition/upcoming", to: "games#upcoming_competition", as: :competition_upcoming
    get "/:competition/today", to: "games#today_competition", as: :competition_today

    get "/dates/:date", to: "dates#show", as: :date_games

    get "/:competition", to: "games#index", as: :competition

    resources :games, only: [:show]
    resources :teams, only: [:show] do
      member do
        get :today
      end
    end
  end
end