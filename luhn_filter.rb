class String
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
    @cc_regex = /([\ \-]*+\d){14,16}/
  end

  def filtered
    start = 0
    while start < @unfiltered.length
      matched = @unfiltered.match @cc_regex, start
      break if matched.nil?

      unsanitized = matched[0] # actual matched string
      digits_only = unsanitized.remove_non_digits
      if digits_only.luhn_check?
        masked = unsanitized.mask_digits 'X'
        # MatchData#offset gives you the range of the first appearance of
        # matched data to the first non matched
        matched_range = matched.offset(0).first .. (matched.offset(0).last-1)
        @filtered[matched_range] = masked
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