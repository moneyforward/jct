module Jct
  class ExciseTaxRate
    attr_reader :rate, :term

    def initialize(rate:, term:)
      @rate = rate
      @term = term
    end

    def is_in_effect_on?(date)
      term.includes?(date)
    end

    def is_in_effect_for?(term)
      self.term.overlaps_with?(term)
    end
  end
end
