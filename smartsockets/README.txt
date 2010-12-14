

How this works.  You run tclsyslogd -d or equivalent in this directory so
it finds syslog.tcl.  Needs polish but it works.

You can then telnet to tclsyslogd's TCP port and when you connect, it'll
start spewing you all the syslog messages it is receiving, in the format
as follows:

l list

where the list is a set of key-value pairs of syslog messages, as such...

l {clock 1292316541 timestamp {Dec 14 02:49:01 } from cfood program nrpe facility daemon priority debug msg {nrpe[41785]: Host address is in allowed_hosts}}

l {clock 1292316541 timestamp {Dec 14 02:49:01 } from cfood program nrpe facility daemon priority debug msg {nrpe[41785]: Handling the connection...}}


You can issue commands to this port.  The commands are:

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
though, don't let just anybody connect to your syslog smartsockets.
