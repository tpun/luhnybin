require 'set'

class String
  # first `n` appearance of characters in `only`
  def first n, only
    return "" if self.length < n

    substring = ""
    count = 0
    self.length.times do |i|
      (i..self.length-1).each do |i|
        char = self[i]
        break if count == n
        substring << char
        count += 1 if only.include? char
      end
    end

    if count == n
      substring
    else
      "" # since we didn't get the requested length
    end
  end

  def mask_digits! start, count, replacement
    self[start..start+count-1] = replacement * count
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
        if passed? unsanitized
          @filtered.mask_digits! n, unsanitized.length, 'X'
          break # since we don't need to test for shorter code
        end
      end
    end
    @filtered
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

  def remove_non_digits unsanitized
    unsanitized.gsub /[A-Z+a-z+\-+\ ]/, ''
  end
end


# # Read from stdin
$stdin.each_line do |line|
$stderr.puts "test: #{line}"
  luhn = LuhnFilter.new line
  $stdout.puts luhn.filtered
end