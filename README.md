

syslogbox - This "log box" contains companion Tcl code libraries to tclsyslogd.

First we have logprocs, an ultra-simple registration system that allows you to create and manage automatically calling multiple Tcl procs when a syslog message is received by tclsyslogd.

Second we have smartsockets, a way to use tclsyslogd as a multiplexing syslog server to apps that have TCP sockets open to it.  You can construct drop patterns to discard routine messages and hone in on anomalous ones, as well as require patterns, which allow you to rapidly exclude all but a few messages from a great many.

You can save and load the drop and require patterns, and it's efficient because the patterns are matched on the server so nonmatching ones aren't transmitted.

Check the README within for details.
