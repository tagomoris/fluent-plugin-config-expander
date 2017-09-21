# fluent-plugin-config-expander

This is a plugin for [Fluentd](http://fluentd.org).

## Requirements

| fluent-plugin-config-expander | fluentd    | ruby   |
|-------------------------------|------------|--------|
| >= 1.0.0                      | >= v0.14.0 | >= 2.1 |
| <  1.0.0                      | <  v0.14.0 | >= 1.9 |

## ConfigExpanderInput, ConfigExpanderOutput

ConfigExpanderInput, ConfigExpanderFilter and ConfigExpanderOutput plugins provide simple configuration template to write items repeatedly.
In `<config>` section, you can write actual configuration for actual input/filter/output plugin, with special directives for loop controls.

And also supports built-in placeholders below:
 * hostname (ex: \_\_HOSTNAME\_\_, \_\_hostname\_\_, ${hostname}, ${HOSTNAME})

## Configuration

For all of input, filter and output (for `<source>`, `<filter>` and `<match>`), you can use 'config_expander' and its 'for' directive like below:

    <match example.**>
      @type config_expander
      <config>
        @type forward
        flush_interval 30s
        <for x in 01 02 03>
          <server>
            host worker__x__.local
            port 24224
          </server>
        </for>
      </config>
    </match>

Configuration above is equal to below:

    <match example.**>
      @type forward
      flush_interval 30s
      <server>
        host worker01.local
        port 24224
      </server>
      <server>
        host worker02.local
        port 24224
      </server>
      <server>
        host worker03.local
        port 24224
      </server>
    </match>

As placeholder, you can use '${varname}' style:

    <match example.**>
      @type config_expander
      <config>
        @type forward
        flush_interval 30s
        <for node in 01 02 03>
          <server>
            host worker${node}.local
            port 24224
          </server>
        </for>
      </config>
    </match>

Nested 'for' directive is valid:

    <match example.**>
      @type config_expander
      <config>
        @type forward
        flush_interval 30s
        <for x in 01 02 03>
          <for p in 24221 24222 24223 24224
            <server>
              host worker__x__.local
              port __p__
            </server>
          </for>
        </for>
      </config>
    </match>

Set hostname into tag in 'tail' input plugin:

    <source>
      @type config_expander
      <config>
        @type tail
        @label @access_events
        format /..../
        path /var/log/access.log
        tag access.log.${hostname}
      </config>
    </source>

Also you can give comma-separated multi values(note no indexed name `${varname}` indice a first element):

    <match example.**>
      @type config_expander
      <config>
        @type forward
        flush_interval 30s
        <for nodeinfo in 01,24224 02,24225>
          <server>
            host worker${nodeinfo[0]}.local
            port ${nodeinfo[1]}
          </server>
        </for>
      </config>
    </match>

## TODO

* more tests
* patches welcome!

## Copyright

* Copyright (c) 2012- TAGOMORI Satoshi (tagomoris)
* License
  * Apache License, Version 2.0

