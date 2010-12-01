#
# logprocs - register multiple procs to be called every for every syslog message
#

namespace eval ::logprocs {
    variable procList
    variable debug

    set procList [list]
    set debug 1

#
# debug - issue a debug message (if enabled)
#
proc debug {message} {
    variable debug

    if {$debug} {
        puts stderr "[lindex [info level [expr [info level] - 1]] 0]: $debug"
    }
}
#
# register - register a proc in the syslog callout list
#
proc register {proc} {
    variable procList

    # if the proc is already registered, don't register it again
    if {[lsearch $procList $proc] >= 0} {
        # don't register it again
        return
    }

    lappend procList $proc
    return
}

#
# cancel - remove a proc from the syslog callout list
#
proc cancel {proc} {
    variable procList

    set which [lsearch $procList $proc]

    # if the proc isn't in the list, just return, like "after cancel" does
    if {$which < 0} {
        return
    }

    set procList [lreplace $procList $which $which]
    return
}

#
# invoke - invoke all registered procs with the message array
#
proc invoke {_message} {
    variable procList
    upvar $_message message

    foreach proc $procList {
        debug "::logprocs::invoke: invoking proc $proc"
        if {[catch {$proc message} catchResult] == 1} {
	    catch {bgerror "got '$catchResult' executing '$proc message'"}
	}
    }
}

}  ; # namespace eval ::logprocs

#
# syslog - called out to from tclsyslogd, invoke registered logprocs
#
proc syslog {_message} {
    upvar $_message message
    ::logprocs::invoke message
}

