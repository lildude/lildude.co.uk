---
layout: post
title: "A Day in the Life of a GitHub Enterprise Support Engineer"
date: 2016-02-10 16:32:02 -0600
tags:
- github
- support
type: post
published: true
---

<!-- SRC: https://github.zendesk.com/agent/tickets/26345 -->

This is a response I sent to Esri for a performance problem caused by a slow responding LDAP server and details how I analysed the support bundle and explained the problem.

---

I've reviewed your support bundle and I can clearly see three spikes in the graphs (these are the same graphs you can see under http(s)://[hostname]/setup/monitor - I've cut the timeframe down to the last 2 hours):

![Load](/assets/load.png)

The graphs are in UTC.

The graphs are always a good place to start when diagnosing performance related problems. In this case we can see there is a clear increase in the number of errors related to babeld_http which is used for user authentication over HTTPS:

![Errors](/assets/errors.png)

... and an increase in the number of gitauth queued requests:

![Queued Requests](/assets/queued-requests.png)

babeld_https uses gitauth to authenticate users. This suggests your users are taking longer than usual to be authenticated and generally indicates a slow or unresponsive LDAP server.

This in turn is leading to an increase in the number of open TCP connections on port 22 and 443:

![Clients](/assets/clients.png)

This indicates the client connections aren't completing as quickly as they were before. It doesn't indicate there's an increase in the number of connections.

At this stage these graphs give us a good indication of the likely cause of the problem: problems with authenticating your users, most likely a slow or unresponsive LDAP server. We can now delve into the log files to find out more.

As we know we're looking at connections to port 22 and 443, specifically 443 due to the increase in errors for babeld_http, the `/var/log/babeld/babeld.log` file is the first place to see if we can spot a likely culprit. The `babeld.log` is in local time, PST in this case, instead of the default UTC. This is a likely carry-over from when you were running 11.10.3xx which gave the option of setting a timezone.

The first thing I like to do is get an idea of the number of new connections in 10min blocks:

```
$ cut -c 1-15 babeld-logs/babeld.log |uniq -c | tail -10
   2533 Wed Nov  4 14:1
   2603 Wed Nov  4 14:2
   2835 Wed Nov  4 14:3
   2786 Wed Nov  4 14:4
   1822 Wed Nov  4 14:5
   2985 Wed Nov  4 15:0
   1496 Wed Nov  4 15:1   
   1842 Wed Nov  4 15:2
   2842 Wed Nov  4 15:3
   1229 Wed Nov  4 15:4
$
```

It looks like you normally average between 2500-2800 connections per 10 mins so it's quite clear there is a dip in the number of new connections during the time frame you've identified.

Looking closer at the HTTPS-specific connections and counting the number of each of the status codes (this tells us if authentication has been successful or not) we see:

```
$ grep proto=http babeld-logs/babeld.log | egrep 'Wed Nov  4 1[45]:[0-9]' | grep -o code=... | sort -rn | uniq -c
    475 code=500
     17 code=404
   6687 code=401
   3054 code=200
      1 code=-1
$
```

Wow!! 6687 401s between 06:25 and 15:44 - that's a lot of 401s. This means you've got a few users attempting to connect with incorrect credentials and on a pretty regular basis. Whilst this adds unnecessary load to your appliance, it's not the most worrying thing; the code=500s are.

Looking at those 500s more closely we see a clear pattern:

```
$ grep proto=http babeld-logs/babeld.log | egrep 'Wed Nov  4 1[45]:[0-5]' | grep code=500 | cut -c 1-15 | uniq -c
     48 Wed Nov  4 14:5
     98 Wed Nov  4 15:0
     82 Wed Nov  4 15:1
    117 Wed Nov  4 15:2
    130 Wed Nov  4 15:3
$
```

They have only occurred since 14:5x PST and tie in perfectly with when you noticed the increase in load.

As I mentioned above, babeld passes HTTP authentication requests to gitauth which logs to `gitauth.log` and `auth.log` so these are the next logs to check. The timestamps in these logs can get a bit confusing as you've changed the timezone of your appliance. The log entries written by the process are in UTC whilst the STDOUT entries are in PST.

As our suspicions are centring around a slow or unresponsive LDAP server, the first thing to look for are complete timeouts:

```
$ grep -i timeout github-logs/gitauth.log
E, [2015-11-04T11:22:03.163711 #5110] ERROR -- : worker=1 PID:9365 timeout (31s > 30s), killing
E, [2015-11-04T11:30:45.168700 #5110] ERROR -- : worker=0 PID:9359 timeout (31s > 30s), killing
E, [2015-11-04T12:02:55.399960 #5110] ERROR -- : worker=0 PID:12177 timeout (31s > 30s), killing
E, [2015-11-04T12:03:01.963947 #5110] ERROR -- : worker=1 PID:30459 timeout (31s > 30s), killing
E, [2015-11-04T15:06:00.146534 #5110] ERROR -- : worker=0 PID:18848 timeout (31s > 30s), killing
E, [2015-11-04T15:35:40.269739 #5110] ERROR -- : worker=0 PID:24125 timeout (31s > 30s), killing
$
```

So we can see gitauth has indeed timed out due to a request taking longer than 30 seconds to respond.

Looking at these closer we can see these have timed waiting to connect to your LDAP server:

```
$ grep -A7 -i timeout github-logs/gitauth.log
E, [2015-11-04T11:22:03.163711 #5110] ERROR -- : worker=1 PID:9365 timeout (31s > 30s), killing
I, [2015-11-04T11:22:03.163919 #5110]  INFO -- : master kill_worker signal=KILL wpid=9365
== worker [9365] USR2 received. dumping backtrace.
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ber/ber_parser.rb:169:in `call'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ber/ber_parser.rb:169:in `getbyte'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ber/ber_parser.rb:169:in `read_ber'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ldap/connection.rb:177:in `block in read'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ldap/instrumentation.rb:16:in `block in instrument'
--
E, [2015-11-04T11:30:45.168700 #5110] ERROR -- : worker=0 PID:9359 timeout (31s > 30s), killing
I, [2015-11-04T11:30:45.168921 #5110]  INFO -- : master kill_worker signal=KILL wpid=9359
== worker [9359] USR2 received. dumping backtrace.
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ber/ber_parser.rb:169:in `call'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ber/ber_parser.rb:169:in `getbyte'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ber/ber_parser.rb:169:in `read_ber'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ldap/connection.rb:177:in `block in read'
/data/github/current/vendor/gems/2.1.6/ruby/2.1.0/gems/net-ldap-0.10.1/lib/net/ldap/instrumentation.rb:16:in `block in instrument'
--
[... truncated for brevity ...]
```

This code is where we establish a connection with your LDAP server and then wait to get a response to that connection. We're not getting it within 30 seconds so we timeout. A similar exception is also logged to the `github-logs/exceptions.log` file.

As we're not getting a response, we restart the unicorn process. During this time any authentication requests will queue until gitauth is running again. This will affect SSH connections too as gitauth also verifies SSH connections. This in turn has a knock-on effect on the load on the appliance and other services then start to suffer too.

The 500 codes we saw in the `babeld.log` file are going to be from individual LDAP requests taking a long time to return and these are a little harder to track down.

Generally we don't dig into this as the timeouts listed above are generally sufficient to indicate there was clearly a communication and performance problem with your LDAP server and you'd need to investigate that side of things further.

If you really want to see an indication of the slow responses, you can do so by looking at the `github-logs/auth.log` file.

Each LDAP authentication attempt results in three lines in the `auth.log` file similar to the following:

```
now="2015-11-04T22:54:09Z" method="GitHub::Authentication::LDAP.ldap_authenticate" at="Searching for user entry" login=user123
now="2015-11-04T22:54:11Z" method="GitHub::Authentication::LDAP.ldap_authenticate_by_ldap_mapping" at="user mapped to ldap dn" login=user123 dn="CN=User Onetwothree,OU=Users,OU=Development,OU=Departments,DC=example,DC=com"
now="2015-11-04T22:54:14Z" ip=10.10.10.10 request_id=09d8e449-d302-4d48-8a63-597c24919d71 repo=myorg/MyRepo.git action=read protocol=http message="Authentication success" method="GitHub::Authentication::Attempt.log" at=success from=git login=user123 raw_login=user123 user_id=148 failure_type=nil failure_reason=nil two_factor_type=nil
```

A difference in time between the first line and the third, as seen above, is usually an indication your LDAP server is slow to respond. These three lines should have very similar time stamps.

If we look at just this one user, we can see some great response times:

```
now="2015-11-04T22:24:33Z" method="GitHub::Authentication::LDAP.ldap_authenticate" at="Searching for user entry" login=user123
now="2015-11-04T22:24:33Z" method="GitHub::Authentication::LDAP.ldap_authenticate_by_ldap_mapping" at="user mapped to ldap dn" login=user123 dn="CN=User Onetwothree,OU=Users,OU=Development,OU=Departments,DC=example,DC=com"
now="2015-11-04T22:24:33Z" ip=10.10.10.10 request_id=c9e78139-323b-4166-b3c4-f3f7159e05e0 repo=user123/TestApp.git action=read protocol=http message="Authentication success" method="GitHub::Authentication::Attempt.log" at=success from=git login=user123 raw_login=user123 user_id=148 failure_type=nil failure_reason=nil two_factor_type=nil
```

... and some pretty poor times right when you noticed the increase in load ...

```
now="2015-11-04T22:53:54Z" method="GitHub::Authentication::LDAP.ldap_authenticate" at="Searching for user entry" login=user123
now="2015-11-04T22:53:57Z" method="GitHub::Authentication::LDAP.ldap_authenticate_by_ldap_mapping" at="user mapped to ldap dn" login=user123 dn="CN=User Onetwothree,OU=Users,OU=Development,OU=Departments,DC=example,DC=com"
now="2015-11-04T22:54:00Z" ip=10.10.10.10 request_id=fd13afb6-9671-4758-8f70-7edff2542b3b repo=myorg/MyRepo.git action=read protocol=http message="Authentication success" method="GitHub::Authentication::Attempt.log" at=success from=git login=user123 raw_login=user123 user_id=148 failure_type=nil failure_reason=nil two_factor_type=nil
```

Part of the increase in time will be down to the increase in load and part of it will be due to the slow LDAP response.

Ultimately, the increase in load on your appliance has been caused by your LDAP server becoming increasingly slow to respond and in several cases completely unresponsive to connections from your appliance.

You'll need to check your LDAP server logs to find out why.

I hope this give you a good demonstration on how we trawl the log files for scenarios like this.

If you have any further questions, please feel free to ask.
