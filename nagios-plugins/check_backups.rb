#!/usr/bin/ruby -w

# require base includes
$srcDir =  File.dirname(__FILE__)
$:.unshift $srcDir

require 'check_last_backup_state'
require 'check_tools'

# main
if __FILE__ == $PROGRAM_NAME

    file_name = ARGV.empty? ? "/etc/nagios/backup-states-to-check.conf" : ARGV.first
    file = File.new(file_name)

    check = BackupCheck.new

    file.each_line do |l|
        next if l =~ /^\s*($|\#)/
        (label, file, age_warn, age_crit) = l.split(/\s+/)
        check.check(label, file, age_warn, age_crit)
    end

    check.state.do_output
    check.state.do_exit
end

