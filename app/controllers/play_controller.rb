class PlayController < ApplicationController
  require 'open-uri'

  def home
  end

  def game
    @grid = generate_grid(9).join(" ")
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    @attempt = params[:shot]
    start_time = params[:start_time].to_datetime
    grid = params[:grid]
    @result = run_game(@attempt, grid, start_time, end_time)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    (0...grid_size).each { grid << ('A'..'Z').to_a.sample }
    grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    ingrid = attempt_in_grid?(attempt, grid)
    translation = get_translation(attempt)

    if ingrid && translation
      score = get_score(attempt, end_time - start_time)
      message(attempt, end_time - start_time, translation, score, "well done")
    elsif ingrid
      message(attempt, end_time - start_time, translation, 0, "not an english word")
    else
      message(attempt, end_time - start_time, translation, 0, "not in the grid")
    end
  end

  def attempt_in_grid?(attempt, grid)
    attempt.upcase.chars.each do |char|
      return false unless grid.include? char
      grid.slice!(grid.index(char))
    end
    true
  end

  def get_translation(word)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{word}"

    open(api_url) do |stream|
      translation = JSON.parse(stream.read)
      if translation["Error"] || !translation["term0"]
        nil
      else
        translation["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
      end
    end
  end

  def get_score(word, time)
    word.size * 10 - time
  end

  def message(attempt, time, translation, score, message)
    {
      attempt: attempt,
      time: time,
      translation: translation,
      score: score,
      message: message
    }
  end
end
