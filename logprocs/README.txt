

registerable multiple proc inteface
===================================

so one thing is register and deregister a proc to get called.

it works like "after".  you register a proc and you get back an ID.

you can pass the ID to deregister the proc or you can, also as with
after, cancel the proc by name.

start tclsyslogd in this directory

edit syslog.tcl to source in your stuff.

To register your proc to be called with syslog messages...

::logprocs::register myproc

To cancel...

::procprocs::cancel myproc


