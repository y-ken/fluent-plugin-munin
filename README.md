fluent-plugin-munin [![Build Status](https://travis-ci.org/y-ken/fluent-plugin-munin.png?branch=master)](https://travis-ci.org/y-ken/fluent-plugin-munin)
===================

## Component
Fluentd Input plugin to fetch munin-node metrics data with custom intervals.

## Installation

### native gem

`````
gem install fluent-plugin-munin
`````

### td-agent gem
`````
/usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-munin
`````

### td-agent2 gem
`````
/usr/sbin/td-agent-gem install fluent-plugin-munin
`````

## Configuration

### Config Sample
`````
<source>
  type            munin
  host            localhost    # Optional (default: localhost)
  port            4949         # Optional (default: 4949)
  interval        10s          # Optional (default: 1m)
  tag_prefix      input.munin  # Required
  # specify munin plugin names by comma separated values.
  service         cpu          # Optional (not specify, fetch all enabled munin metrics)
  # inserting hostname into record.
  record_hostname yes          # Optional (default: no)
  # converting values type from string to number.
  convert_type    yes          # Optional (default: no)
  # metrics datasets to be nested or separated record.
  nest_result     no           # Optional (default: no)
  nest_key        data         # Optional (default: result) 
</source>

<match input.munin.*>
  type stdout
</match>
`````

### Output Sample
record_hostname: no, nest_result: no  #DEFAULT
`````
input.munin.cpu: {"service":"cpu","user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}
`````

tag_prefix: input.${hostname}-munin, record_hostname: yes, nest_result: no
`````
input.myhost.example.com-munin.cpu: {"hostname":"myhost.example.com","service":"cpu","user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}
`````

record_hostname: yes, nest_result: no
`````
input.munin.cpu: {"hostname":"myhost.example.com","service":"cpu","user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}
`````

record_hostname: yes, nest_result: no, convert_type: yes  #RECOMMEND
`````
input.munin.cpu: {"hostname":"myhost.example.com","service":"cpu","user":113183,"nice":340,"system":26584,"idle":74205345,"iowait":26134,"irq":1,"softirq":506,"steal":0,"guest":0}
`````

record_hostname: yes, nest_result: yes, nest_key: data
`````
input.munin.cpu: {"hostname":"myhost.example.com","service":"cpu","data":{"user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}}
`````

### MongoDB find example
record_hostname: yes, nest_result: yes, convert_type: yes
`````
> use munin
> db.cpu.find({ "data.iowait" : { $gt : 200000 } })
`````

### Example

* Example1: how to send munin metrics to treasuredata.<br>
https://github.com/y-ken/fluent-plugin-munin/blob/master/example.conf

* Example2: how to send munin metrics to mongoDB.<br>
https://github.com/y-ken/fluent-plugin-munin/blob/master/example2.conf


## TODO
Pull requests are very welcome!!

## Copyright

Copyright © 2012- Kentaro Yoshida (@yoshi_ken)

## License

Apache License, Version 2.0
