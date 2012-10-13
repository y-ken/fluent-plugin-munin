fluent-plugin-munin
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
  record_hostname yes          # Optional (yes/no)
  # multi row results to be nested or separated record.
  nest_result     no           # Optional (yes/no)
  nest_keyname    data         # Optional (default: result) 
</source>

<match input.munin.*>
  type stdout
</match>
`````

### Output Sample
record_hostname: no, nest_result: no
`````
input.munin.cpu: {"service":"cpu","user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}
`````

record_hostname: yes, nest_result: no
`````
input.munin.cpu: {"hostname":"myhost.example.com","service":"cpu","user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}
`````

record_hostname: yes, nest_result: yes
`````
input.munin.cpu: {"hostname":"myhost.example.com","service":"cpu","data":{"user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}}
`````

## TODO
patches welcome!

## Copyright

Copyright © 2012- Kentaro Yoshida (@yoshi_ken)

## License

Apache License, Version 2.0
