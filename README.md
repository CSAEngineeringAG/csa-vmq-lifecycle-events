# vmq_lifecycle_events

Plugin to publish lifecycle events to a $SYS topic on VerneMQ

## Build

You must have a recent version of Erlang installed (it's recommended to use the
same one VerneMQ is compiled for, typically > 17). To compile do:

    $ rebar3 compile


Then enable the plugin using:

    $ vmq-admin plugin enable --name vmq_lifecycle_events --path /path/to/plugin

Or if you start the plugin via `vernemq.conf`:

    plugins.vmq_lifecycle_events = on
    plugins.vmq_lifecycle_events.path = /path/to/plugin
