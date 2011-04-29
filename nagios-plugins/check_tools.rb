#!/usr/bin/ruby
require 'time'

# a class that keeps messages that happen through a state check
# and does the output formatting and exit accordingly
class CheckState
    attr_reader :errors, :warnings, :oks

    def initialize
        @errors = []
        @warnings = []
        @oks = []
    end

    def fatal(err)
        errors << err
        do_output
        do_exit
    end

    def format(label, msg)
        msg_str = msg.join(", ")
        if msg_str.length > 150
            msg_str = "#{msg_str[0..97]}..."
        end
        return "#{label} #{msg_str}"
    end

    def out_end
	do_output
	do_exit
    end

    def do_exit
        if not errors.empty?
            exit 2
        elsif not warnings.empty?
            exit 1
        else
            exit 0
        end
    end

    def do_output
        if not errors.empty?
            puts format("ERR", errors)
        elsif not warnings.empty? 
            puts format("WARN", warnings)
        else
            puts format("OK", oks)
        end
    end

end

QUANTIFIERS = [["s", 60], ["m", 60], ["h", 24], ["d", 365], ["y",9999999]]
QUANT_TABLE = {}
begin
    factor = 1
    QUANTIFIERS.each do |sym, next_fact|
        QUANT_TABLE[sym] = factor
        factor *= next_fact
    end
end


# Format a time interval for human readibility
# (surprised I din't find it in the std lib)
def format_interval(sec)
    time = sec.to_i
    res=[]
    for (mark, lim) in QUANTIFIERS
        res.unshift "#{time % lim}#{mark}"
        if time < lim
            break
        else
            time = time / lim
        end
    end
    return res.join("")
end

def parse_interval(int)
    res = 0
    int.scan(/\s*(\d+)\s*(s|m|h|d|y)?,?\s*/i).each do |token|
        (num, sym) = token
        factor = QUANT_TABLE[sym.downcase]
        raise "Unknown quantifier: #{quant}" if factor.nil?
        res += num.to_i * factor
    end
    return res
end

def sys(*args)
	system(*args)
	if $?.exitstatus > 0
		raise "Error: #{args.join(" ")} failed with exit code #{$?.exitstatus}"
	end
end


