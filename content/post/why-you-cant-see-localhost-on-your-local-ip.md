---
title: "Why localhost is local: 127.0.0.1 vs 0.0.0.0"
date: 2018-04-22T19:18:45+01:00
---
*Note: this post is based on experience with Linux.*

We've all been there - you're working on a server on your local machine and
need to show it to someone else on your local network. You grab your machine's
IP using `netstat`, `ifconfig`, or similar and send it over. And... they can't
connect.

If there isn't an issue with your firewall settings, and you Google the right
thing, you may find a StackOverflow post telling you that your server has to
bind on `0.0.0.0` rather than `127.0.0.1`. But what does this mean and how does
it work?

# The Loopback Interface
Network Interfaces are objects within the kernel that represent an entry point
for the host on a particular network for sending/receiving packets. They can be
used to represent physical Network Interface Cards but they can also be
virtualised for other purposes.

The purpose of the loopback interface, `lo`, is to give the host the ability to
efficiently send packets to itself. The kernel implements this by returning
packets straight back to the interface without going any deeper into the
kernel's networking stack.

When your server process binds to `127.0.0.1` it is bound to the `lo` Network
Interface.  This is why you cannot connect to it from your local network - the
`lo` interface can only be reached from your local machine.

# 0.0.0.0 Special Case
If you can't connect to the server process from your local network when it is
bound to `127.0.0.1`, what should you do instead? One option is to bind to your
machine's address on your local network (`192.168.1.12` or whatever). However,
it can be quite tedious to work out which interface is connected to your local
network and the IP that has been assigned to that interface.

Another option is to bind to an address that can be routed to from *all*
Network Interfaces. This is what happens when you bind to `0.0.0.0`.

`0.0.0.0` is a non-routable address that, by convention, will receive packets
from every Network Interface on the host.

So, the next time you want to host something on your local network, remember to
bind to `0.0.0.0`.
