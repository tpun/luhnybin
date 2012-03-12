class String
  # Returns the first appearance of the matched substring along with
  # the range indicating the index of the first and last characters.
  def possible_credit_card_match from=0
    matched = match /([\ \-]*+\d){14,16}/, from
    return nil if matched.nil?

    # MatchData#offset gives you the range of the first appearance of
    # matched data to the first non matched
    [matched[0], matched.offset(0).first..(matched.offset(0).last-1)]
  end

  def mask_digits replacement
    gsub /\d/, replacement
  end

  def remove_non_digits
    self.gsub /[^\d]/, ''
  end

  def luhn_check?
    sum = 0
    length.times do |n|
      c = self[-(1+n)] # count from right
      digit = c.to_i
      if n.odd? # every other digit
        digit *= 2
        sum += (digit/10) + (digit%10)
      else
        sum += digit
      end
    end

    sum % 10 == 0
  end
end

class LuhnFilter
  def initialize unfiltered
    @unfiltered = unfiltered
    @filtered = unfiltered.clone
  end

  def filtered
    start = 0
    while start < @unfiltered.length
      unsanitized, matched_range = @unfiltered.possible_credit_card_match start
      break if unsanitized.nil?

      digits_only = unsanitized.remove_non_digits
      if digits_only.luhn_check?
        @filtered[matched_range] = unsanitized.mask_digits 'X'
        start = matched_range.first
      end

      start += 1
    end

    @filtered
  end
end


# # Read from stdin
$stdin.each_line do |line|
  luhn = LuhnFilter.new line
  $stdout.puts luhn.filtered
end