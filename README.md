puppet-irc
==========

Description
-----------

A Puppet report handler for sending notifications of failed runs to IRC.

Requirements
------------

* `carrier-pigeon`
* `puppet` (version 2.6.5 and later)

Installation & Usage
--------------------

1.  Install the `carrier-pigeon` gem on your Puppet master

        $ sudo gem install carrier-pigeon

2.  Install puppet-irc as a module in your Puppet master's module
    path.

3.  Update the `irc_server` variable in the `irc.yaml` file with
    your IRC connection details. If you wish to enable an SSL
    connection to your IRC server then set the `irc_ssl` option to
    `true`. If you need to specify a channel password please specify
    the `irc_password` option. If you are getting register_first error
    please specify irc_register_first as true. 
    If you specify the `github_user` and `github_password` options 
    the report processor will create a Gist containing the log output 
    from the run. The Gist will be linked in the IRC notification.

4.  Copy `irc.yaml` to `/etc/puppet`.
    NOTE: Remove any configurations items you're not setting
    if you are using the default file.

5.  Enable pluginsync and reports on your master and clients in `puppet.conf`

        [master]
        report = true
        reports = irc
        pluginsync = true
        [agent]
        report = true
        pluginsync = true

6.  Run the Puppet client and sync the report as a plugin

Author
------

James Turnbull <james@lovedthanlost.net>

License
-------

    Author:: James Turnbull (<james@lovedthanlost.net>)
    Copyright:: Copyright (c) 2011 James Turnbull
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
