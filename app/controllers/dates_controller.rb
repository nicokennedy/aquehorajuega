class DatesController < ApplicationController
  def show
    @date = Date.parse(params[:date])

    @games = Game
      .includes(:home_team, :away_team, :competition)
      .where(starts_at: @date.beginning_of_day..@date.end_of_day)
      .order(:starts_at)
  rescue ArgumentError
    raise ActiveRecord::RecordNotFound
  end
end