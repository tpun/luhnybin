require 'set'

class String
  # first `n` appearance of characters in `only`
  def first n, only
    return "" if self.length < n

    substring = ""
    count = 0
    self.length.times do |i|
      break if count == n
      char = self[i]
      substring << char
      count += 1 if only.include? char
    end

    if count == n
      substring
    else
      "" # since we didn't get the requested length
    end
  end

  def mask_digits! start, count, replacement
    (start..start+count-1).each do |i|
      self[i] = replacement if self[i] == self[i].to_i.to_s
    end
  end

  def remove_non_digits
    self.gsub /[A-Z+a-z+\-+\ ]/, ''
  end

  def luhn_check?
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
end

class LuhnFilter
  MinLength = 14
  MaxLength = 16

  def initialize unfiltered
    @unfiltered = unfiltered.chomp
    @filtered = unfiltered.clone
  end

  def filtered
    only = Set.new (0..9).map &:to_s
    @unfiltered.length.times do |n|
      break if @unfiltered.length - n < MinLength

      (MinLength..MaxLength).reverse_each do |length|
        unsanitized = @unfiltered[n..-1].first length, only
        if unsanitized.luhn_check?
          @filtered.mask_digits! n, unsanitized.length, 'X'
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