#
#
#
#
#

namespace eval ::syslogterp {
    variable sockets
    variable serverPort
    variable serverSock

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
    set serverSock [socket -server ::syslogterp::accept_connection $serverPort]
}

#
# accept_connection - accept a client connection
#
proc accept_connection {sock ip port} {
    variable sockets

    log "accept connection socket $sock, ip $ip, port $port"
    fconfigure $sock -blocking 0 -translation auto
    fileevent $sock readable [list ::syslogterp::remote_receive $sock]

    set sockets($sock) [interp create -safe]
    $sockets($sock) eval {
        proc syslog {arrayName} {}
    }
    puts $sock "syslogterp 1.0"
}

#
# handle_eof - do the various bits of cleanup associated with a socket closing,
#  including destroying the safe slave interpreter
#
proc handle_eof {sock} {
    variable sockets

    log "EOF from socket $sock"
    catch {close $sock}
    interp destroy $sockets($sock)
    unset sockets($sock)
}

#
# remote_receive - receive a message from a remote connection
#
proc remote_receive {sock} {
    variable sockets

    if {[eof $sock]} {
        handle_eof $sock
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
        log [list e $catchResult]
        puts $sock [list e $catchResult]
    } else {
        log [list r $catchResult]
        puts $sock [list r $catchResult]
    }
    flush $sock
    return
}


} ; # namespace syslogterp

::syslogterp::setup_server
vwait dieZ
