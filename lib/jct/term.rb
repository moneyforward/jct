module Jct
  class Term
    attr_reader :start_on, :end_on

    def initialize(start_on:, end_on:)
      raise ArgumentError.new('start_on data-type must be Date') unless start_on.is_a?(Date)
      raise ArgumentError.new('end_on data-type must be Date') unless end_on.is_a?(Date)
      raise ArgumentError.new('start_on must not be after than end_on') if start_on > end_on

      @start_on = start_on
      @end_on = end_on
    end

    def includes?(date)
      start_on <= date && date <= end_on
    end

    def overlaps_with?(term)
      # Patterns that self and term **donot** overlap
      #   term.end_on < self.start_on
      #     self:       |---|
      #     term: |---|
      #   OR
      #   self.end_on < term.start_on
      #     self:       |---|
      #     term:             |---|
      !(term.end_on < start_on || end_on < term.start_on)
    end

    def number_of_days
      (end_on - start_on).to_i + 1
    end

    def number_of_days_that_overlap_with(term)
      return 0 unless overlaps_with?(term)

      if start_on <= term.start_on && term.end_on <= end_on
        # self:  |-------|
        # term:    |---|
        term.number_of_days
      elsif term.start_on <= start_on && end_on <= term.end_on
        # self:    |---|
        # term:  |-------|
        number_of_days
      elsif term.start_on <= start_on && term.end_on <= end_on
        # self:    |---|
        # term: |---|
        Term.new(start_on: start_on, end_on: term.end_on).number_of_days
      else
        # self:    |---|
        # term:       |---|
        Term.new(start_on: term.start_on, end_on: end_on).number_of_days
      end
    end
  end
end
