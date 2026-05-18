Rails.application.routes.draw do
  get "/sitemap.xml", to: redirect("/sitemap.xml.gz")
  get "/sitemap.xml.gz", to: redirect("/sitemap.xml.gz")

  get 'dates/show'
  get 'teams/show'

  scope "(:locale)", locale: /es|en|pt/ do
    root "games#index"

    get "/dates/:date", to: "dates#show", as: :date_games
    get "/:competition", to: "games#index", as: :competition

    resources :games, only: [:show]
    resources :teams, only: [:show]
  end
end