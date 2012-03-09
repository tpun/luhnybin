class LuhnFilter
  def initialize unfiltered
    @unfiltered = unfiltered.chomp
  end

  def filtered
    return masked @unfiltered if passed?
    @unfiltered
  end

  def passed?
    digits = remove_non_digits
    length = digits.length
    return false unless (14..16).cover? length

    sum = 0
    length.times do |n|
      c = digits[-(1+n)]
      digit = c.to_i
      if n.odd?
        digit *= 2
        sum += (digit/10) + (digit%10)
      else
        sum += digit
      end
    end
    sum % 10 == 0
  end

  def masked string
    string.gsub /[0123456789]/, 'X'
  end

  def remove_non_digits
    @unfiltered.gsub /[A-Z+a-z+\-+\ ]/, ''
  end
end


# # Read from stdin
$stdin.each_line do |line|
  luhn = LuhnFilter.new line
  $stdout.puts luhn.filtered
end