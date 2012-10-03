fluent-plugin-munin
===================

## Component
Fluentd Input plugin. fetch munin-node metrics data with custom intervals.

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
  server          localhost
  port            4949
  interval        10
  tag_prefix      input.munin
  service         cpu,df
  record_hostname yes
</source>

<match input.munin.*>
  type stdout
</match>
`````

### Output Sample
`````
input.munin.cpu: {"hostname":"myhost.example.com","service":"cpu","user":"113183","nice":"340","system":"26584","idle":"74205345","iowait":"26134","irq":"1","softirq":"506","steal":"0","guest":"0"}
`````

## TODO
patches welcome!

## Copyright

Copyright © 2012- Kentaro Yoshida (@yoshi_ken)

## License

Apache License, Version 2.0
