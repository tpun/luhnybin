require 'set'

class String
  # first `n` appearance of characters in `only` given
  # it's a string consisted only chacaters in `valid`
  def first n, only, valid
    return "" if self.length < n

    substring = ""
    count = 0
    self.length.times do |i|
      char = self[i]
      break if count == n or !valid.include? char

      substring << char
      count += 1 if only.include? char
    end

    if count == n
      substring
    else
      "" # since we didn't get the requested length
    end
  end

  def digits?
    self == self.to_i.to_s
  end

  def mask_digits! start, count, replacement
    (start..start+count-1).each do |i|
      self[i] = replacement if self[i].digits?
    end
  end

  def remove_non_digits
    self.gsub /[A-Z+a-z+\-+\ ]/, ''
  end

  def luhn_check? length_range
    digits = remove_non_digits

    length = digits.length
    return false unless length_range.cover? length

    sum = 0
    length.times do |n|
      c = digits[-(1+n)]
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
  MinLength = 14
  MaxLength = 16

  def initialize unfiltered
    @unfiltered = unfiltered.chomp
    @filtered = unfiltered.clone
  end

  def filtered
    digit_set = Set.new ((0..9).map &:to_s)
    valid_set = digit_set + Set.new(['-', ' '])
    length_range = (MinLength..MaxLength)

    (0..@unfiltered.length-MinLength).each do |start|
      (MinLength..MaxLength).reverse_each do |length|
        unsanitized = @unfiltered[start..-1].first length, digit_set, valid_set
        if unsanitized.luhn_check? length_range
          @filtered.mask_digits! start, unsanitized.length, 'X'
          break # since we don't need to test for shorter code
        end
      end
    end
    @filtered
  end
end


# # Read from stdin
$stdin.each_line do |line|
  luhn = LuhnFilter.new line
  $stdout.puts luhn.filtered
end