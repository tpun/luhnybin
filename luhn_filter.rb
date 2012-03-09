class String
  def substrings min_length, only
    out = []
    if self.length >= min_length
      self.length.times do |n|
        break if self.length - n < min_length

        substring = ""
        substring_count = 0 # actual count disguarding ignored
        self[n..-1].split("").each do |char|
          break if substring_count == min_length

          substring << char
          substring_count += 1 if only.include? char
        end
        out << substring if substring_count==min_length
      end
    end
    out
  end
end

class LuhnFilter
  def initialize unfiltered
    @unfiltered = unfiltered
  end

  def filtered
    only = (0..9).map &:to_s
    possible_substrings((14..16), only).each do |unsanitized|
      return masked unsanitized if passed? unsanitized
    end
    @unfiltered
  end

  def possible_substrings range, ignored
    out = []
    range.reverse_each do |n|
      out += @unfiltered.substrings n, ignored
    end
    out
  end

  def passed? unsanitized
    digits = remove_non_digits unsanitized

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

  def masked matched
    replacement = matched.gsub /[0-9]/, 'X'
    @unfiltered.gsub matched, replacement
  end

  def remove_non_digits unsanitized
    unsanitized.gsub /[A-Z+a-z+\-+\ ]/, ''
  end
end


# # Read from stdin
$stdin.each_line do |line|
  luhn = LuhnFilter.new line
  $stdout.puts luhn.filtered
end