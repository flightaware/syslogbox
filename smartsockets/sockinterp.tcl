#
#
#
#
#

namespace eval ::syslogterp {
    variable sockets
    variable serverPort
    variable serverSock
    variable slaveCodeBase

    set serverPort 23456

proc log {message} {
    puts stderr "syslogterp: $message"
}
#
# setup_server - setup to receive TCP connections on the server port
#
proc setup_server {} {
    variable serverPort
    variable serverSock
    variable slaveCodeBase

    set serverSock [socket -server ::syslogterp::accept_connection $serverPort]

    # load the slave code base
    set fp [open dropper.tcl]
    set slaveCodeBase [read $fp]
    close $fp
}

#
# accept_connection - accept a client connection
#
proc accept_connection {sock ip port} {
    variable sockets
    variable slaveCodeBase

    log "accept connection socket $sock, ip $ip, port $port"
    fconfigure $sock -blocking 0 -translation auto -buffering line
    fileevent $sock readable [list ::syslogterp::remote_receive $sock]

    set sockets($sock) [interp create -safe]
    $sockets($sock) eval $slaveCodeBase

    # alias "quit" in the slave interpreter to invoke remote_disconnect here
    $sockets($sock) alias quit ::syslogterp::remote_disconnect $sock
    $sockets($sock) alias puts ::syslogterp::slave_puts $sock
    $sockets($sock) alias test ::syslogterp::test_syslog

    puts $sock "syslogterp 1.0"
}

proc syslog {_array} {
    log "syslog"
    variable sockets

    upvar $_array array

    log "syslog called, array contains '[array get array]'"

    set command "unset -nocomplain ::message; array set ::message [list [array get array]]; syslog ::message"

    log "syslog command is '$command'"

    foreach sock [array names sockets] {
        log "sending command to sock $sock"
        if {[catch {$sockets($sock) eval $command} catchResult] == 1} {
	    log "got '$catchResult' executing command in sock $sock"
	}
	update
    }
}

proc test_syslog {} {
    log "test_syslog invoked"
    set message(foo) testfoo
    set message(bar) testbar

    log "invoking syslog with message [array get message]"
    syslog message
}

#
# remote_disconnect - proc invoked by "quit" in the slave to disconnect
#
proc remote_disconnect {sock} {
    log "remote disconnect from $sock"
    puts $sock [list r [list]]
    disconnect $sock
}

#
# remote_disconnect - proc invoked by "quit" in the slave to disconnect
#
proc slave_puts {sock line} {
    log "slave_puts $sock $line"
    puts $sock $line
}

#
# handle_eof - do the various bits of cleanup associated with a socket closing,
#  including destroying the safe slave interpreter
#
proc handle_eof {sock} {
    variable sockets

    log "EOF from socket $sock"
    disconnect $sock
}

proc disconnect {sock} {
    variable sockets

    catch {close $sock}
    interp delete $sockets($sock)
    unset sockets($sock)
}

#
# remote_receive - receive a message from a remote connection
#
proc remote_receive {sock} {
    variable sockets

    if {[eof $sock]} {
        handle_eof $sock
	return
    }

    if {[gets $sock line] < 0} {
        if {[eof $sock]} {
	    handle_eof $sock
	}
	# if gets returns < 0 and not EOF, we're nonblocking and haven't
	# gotten a complete line yet... keep waiting
	return
    }

    log "got '$line' from $sock"
    if {[catch {$sockets($sock) eval $line} catchResult] == 1} {
        log [list e $catchResult $::errorInfo]
        puts $sock [list e $catchResult $::errorInfo]
    } else {
        # if there is no socket, they disconnected
        if {![info exists sockets($sock)]} {
	    return
	}
        log [list r $catchResult]
        puts $sock [list r $catchResult]
    }
    flush $sock
    return
}

} ; # namespace syslogterp

