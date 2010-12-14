#
#
#
#

#
# syslog - called in the slave interpreter when tclsyslogd receives messages
#
proc syslog {_message} {
    upvar $_message message

    # if we've been told to drop it, drop it
    if {[check_for_drops message]} {
        return ""
    }

    puts [list l [array get message]]
}

#
# drop - record patterns for the syslog keyword
#
proc drop {keyword args} {
    variable dropArray

    foreach pattern $args {
	lappend dropArray($keyword) $pattern
    }
}

#
# check_for_drops - return 1 if some drop parameter matches the message
#
proc check_for_drops {_message} {
    variable dropArray
    upvar $_message message

    foreach keyword [array names message] {
        if {![info exists dropArray($keyword)]} {
	    continue
	}

	foreach pattern $dropArray($keyword) {
	    #puts "comparing keyword '$keyword' to pattern '$dropArray($keyword)'"
	    if {[string match $pattern $message($keyword)]} {
	        return 1
	    }
	}
    }

    return 0
}

proc save {} {
    variable dropArray

    puts "load [array get dropArray]"
}

proc load {args} {
    variable dropArray

    foreach "key value" $args {
        set dropArray($key) $value
    }
}
