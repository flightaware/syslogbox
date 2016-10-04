
live syslog groping tool that does the filtering at the server

How this works.  You run tclsyslogd (-d) or equivalent in this directory so
it finds this syslog.tcl.  Needs polish but it works.

You can then telnet to tclsyslogd's TCP port (23456 by default) and when you
connect, it'll start spewing you all the syslog messages it is receiving, in
the format as follows:

l string

where the string is formatted output of the key-value pairs of received
syslog messages, as such...

log clock: 1292428107, timestamp: Dec 15 09:48:27 , host: foxtrot, program: balancer, priority: info, facility: local5, msg: balancer[65141]: glyde.jfk.flightaware.com took 2 seconds to make map 13645369

You can issue commands to this port to start and stop the flow, and to filter
what you receive.

Multiple connections are each handled separately, and tclsyslogd provides
full "normal" syslogd functionality as well as the Tcl callouts.

The commands are handled on the server side by a safe interpreter.  You can
issue Tcl commands to this interpreter, including creating procs and so forth.

The provided commands are:

stop - stop forwarding log messages

start - start forwarding log messages

drop - stop sending messages matching a certain pattern

    examples:

        drop facility mail

	drop from cfood

	drop program nrpe

    You can drop as many things as you want, including multiple of the same
    facility.  Also note that you can specify multiple matches in one pass.

        drop program sm-mta nrpe

	drop priority info debug


    Again, these are cumulative.  One way to use this, you start dropping
    routine messages that you recognize as OK until you are getting few
    messages and the ones you are getting have interesting anomalies among them.

    The pattern is glob-style.


require - require messages to match a certain pattern

    examples:

        require program balancer


    If you require specific attributes, they must be present in the message
    for it to be forwarded to you.

    This is a good way to cut right through the noise and focus on a
    specific host, program, facility or priority, etc.

unrequire - reverse the effect of a previous "require"

    example:

	unrequre program balancer

    Undoes a previous "require", making the selector less selective.

save - "save" the current drop/require configuration

    The server doesn't provide any storage currently, so save just emits
    a load command that you can copy and then past back into this thing
    next time you connect and it should be set up the way it was before.

Since there is no authentication, connections are required to come from 
127.0.0.1.

Since it is a safe interpreter, theoretically even maliciously crafted
code could not gain a toehold to take over your system.  It could easily
do denial of service to other tclsyslogd code by doing an infinite loop
or whatever -- the resource limiting capabilities of "interp limit"
should be explored to make denial of serivce even less likely.  Mostly,
though, don't let just anybody connect to your syslog smartsockets for
lots of other good reasons like you might leak certain passwords or internal
information in your messages that could help lead to a compromise.

