#
#
#
#

source sockinterp.tcl

proc syslog {_message} {
    upvar $_message message

    #parray message

    ::syslogterp::syslog message
    update
}

puts "sockinterp loaded"


::syslogterp::setup_server

