#
#
#
# $Id: syslog.tcl,v 1.1 2009-02-09 09:44:15 karl Exp $
#

source logprocs.tcl

proc syslog_parray {messageArray} {
    upvar $messageArray message

    parray message
    puts ""
}

::logprocs::register syslog_parray

