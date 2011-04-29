#!/usr/bin/ruby -w

# require base includes
$srcDir =  File.dirname(__FILE__)
$:.unshift $srcDir

require 'check_tools'

class BackupCheck
    attr_accessor :state

    def initialize(state=CheckState.new)
        @state = state
    end
    def check(label, file, age_warn_str, age_crit_str)

        age_warn = parse_interval(age_warn_str)
        age_crit = parse_interval(age_crit_str)

        unless File.exist? file 
            state.errors << "file #{file} does not exist" 
            return state
        end

        begin
            data = File.read file
        rescue Error => e
            state.errors << "error reading file #{file}: #{e}"
        end

        data.chomp!

        (date, time, msg, result_str) = data.split(" ")
        result = result_str.to_i

        if result >= 2
            state.errors << "#{label}: last result ERR (#{result})"
        elsif result > 0 
            state.warnings << "#{label}: last result WARN (#{result})"
        else
            state.oks << "#{label}: last result OK (#{result})"
        end

        now = Time.now
        timestamp = Time.parse("#{date} #{time}")
        age = now - timestamp
        if age < 0
            state.errors << "#{label}: timestamp should not be in the future"
        elsif age > age_crit
            state.errors << "#{label}: state way too old (#{format_interval(age)} > #{format_interval(age_crit)})"
        elsif age > age_warn
            state.warnings << "#{label}: state too old (#{format_interval(age)} > #{format_interval(age_warn)})"
        else
            state.oks << "#{label}: age ok (#{format_interval(age)})"
        end
    end
end

# main
if __FILE__ == $PROGRAM_NAME
    age_warn=24*3600
    age_crit=36*3600

    state = CheckState.new

    #demostr="2009-12-04 18:44:53+01:00 OK 0"
    state.fatal "Call syntax: #{$0} <state_file> <warn_age> <crit_age>" if ARGV.empty?
    file = ARGV.first
    age_warn = ARGV[1].to_i if ARGV.size > 1
    age_crit = ARGV[2].to_i if ARGV.size > 2

    check = BackupCheck.new(state)
    check.check(File.basename(file), file, age_warn, age_crit)

    state.do_output
    state.do_exit
end

