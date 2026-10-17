module Lottery
  class FakeClient
    attr_reader :open_options, :calls

    def initialize(balance: build_balance, entries: [], errors: {})
      @balance = balance
      @entries = entries
      @errors = errors
      @calls = []
    end

    def open(**options)
      @open_options = options
      yield self
    end

    def balance
      called(:balance)
      @balance
    end

    def purchase_history(from:, page: 1, per_page: 100)
      called(:purchase_history, from:, page:, per_page:)
      @entries.slice((page - 1) * per_page, per_page) || []
    end

    def buy_lotto645(tickets, round:)
      called(:buy_lotto645, tickets:, round:)
      DhLottery::Lotto645::PurchaseResult.new(
        round: round,
        draw_date: Date.current,
        pay_limit_date: Date.current + 365,
        slots: tickets.each_with_index.map do |ticket, index|
          numbers = ticket.auto? ? [ 3, 11, 19, 27, 35, 43 ] : ticket.numbers
          DhLottery::Lotto645::PurchasedSlot.new(slot: DhLottery::Lotto645::SLOT_LETTERS[index], mode: ticket.mode, numbers: numbers)
        end,
        total_amount: tickets.size * DhLottery::Lotto645::PRICE_PER_GAME,
        dry_run: open_options[:dry_run],
        raw: {}
      )
    end

    def called?(name)
      calls.any? { |call_name, _| call_name == name }
    end

    def self.build_entry(**attributes)
      DhLottery::LedgerEntry.new(**{
        purchased_on: Date.current,
        product_name: "로또6/45",
        round: 1200,
        barcode: "12345 67890",
        quantity: 1,
        result: "미추첨",
        prize_amount: 0,
        draw_date: Date.current,
        order_no: "ORDER-1",
        details: nil,
        raw: {}
      }.merge(attributes))
    end

    private

    def called(name, **arguments)
      @calls << [ name, arguments ]
      raise @errors[name] if @errors.key?(name)
    end

    def build_balance(purchasable: 41_000, total_deposit: 45_000)
      DhLottery::Balance.new(
        total_deposit: total_deposit, purchasable: purchasable, unpurchasable: 4_000,
        reserved: 0, withdrawing: 0, monthly_purchased: 5_000, raw: {}
      )
    end
  end

  module FakeClientHelper
    def use_fake_lottery_client(fake_client = Lottery::FakeClient.new)
      previous_client_class = Lottery::ClientSession.client_class
      Lottery::ClientSession.client_class = fake_client
      yield fake_client
    ensure
      Lottery::ClientSession.client_class = previous_client_class
    end

    def create_lottery_account(user, **attributes)
      Lottery::Account.create!(user_id: user.id, login_id: "lotto_user", password: "lotto_pass", **attributes)
    end
  end
end
