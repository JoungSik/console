module Lottery
  class TicketOrder
    include ActiveModel::Model
    include ActiveModel::Attributes

    GAME_SLOTS = DhLottery::Lotto645::SLOT_LETTERS
    Game = Data.define(:letter, :selected, :numbers)

    attribute :round, :integer
    attribute :request_token, :string

    validate :tickets_must_be_valid
    validate :round_must_be_upcoming
    validate :sales_must_be_open

    def initialize(games: nil, **attributes)
      super(**attributes)
      @games = build_games(games)
      self.round ||= upcoming_round
    end

    attr_reader :games

    def selected_games
      games.select(&:selected)
    end

    def tickets
      @tickets ||= DhLottery::Lotto645::Ticket.coerce_all(selected_games.map(&:numbers))
    end

    def summary
      tickets.each_with_index.map do |ticket, index|
        numbers = ticket.auto? ? "" : ticket.numbers.join(" ")
        "#{GAME_SLOTS.fetch(index)} #{ticket.mode_name} #{numbers}".strip
      end
    end

    def total_amount
      tickets.size * DhLottery::Lotto645::PRICE_PER_GAME
    end

    def draw_date
      schedule.draw_date
    end

    def upcoming_round
      schedule.round
    end

    private

    def build_games(games_params)
      selections = games_params.to_h.transform_keys(&:to_s)
      GAME_SLOTS.each_with_index.map do |letter, index|
        selection = selections.fetch(index.to_s, {}).to_h.transform_keys(&:to_s)
        Game.new(
          letter: letter,
          selected: games_params.nil? ? index.zero? : ActiveModel::Type::Boolean.new.cast(selection["selected"]) || false,
          numbers: selection["numbers"].to_s.strip
        )
      end
    end

    def schedule
      @schedule ||= DhLottery::Lotto645::DrawScheduler.new.upcoming
    end

    def tickets_must_be_valid
      tickets
    rescue DhLottery::ValidationError => error
      errors.add(:base, :invalid_tickets, detail: error.message)
    end

    def round_must_be_upcoming
      errors.add(:base, :round_changed) unless round == upcoming_round
    end

    def sales_must_be_open
      errors.add(:base, :sales_closed) if schedule.risky?
    end
  end
end
