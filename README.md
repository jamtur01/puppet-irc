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

3.  Copy `irc.yaml` to `/etc/puppet` and modify configuration settings to your
    fit your needs. NOTE: Remove any configurations items you're not setting.
    Available options are decribed below:
    * `irc_server`: URI containing the channel connection details. Example: `irc://puppetbot:password@irc.freenode.net:6667#channel`
    * `irc_ssl`: set to `true` if you wish to enable an SSL connection to your IRC server.
    * `irc_password`: Specify the channel password here if needed.
    * `irc_register_first` : set to `true` if you are getting register_first error.
    * `irc_join`: set to `false` if you wish to disable parts/joins/quits messages.
    * `github_user`: github.com user account. If specified, the report processor will create a Gist containing the log output from the run and link it in the IRC notification.
    * `github_password`: above github user's password.
    * `parsed_reports_dir`: path to a directory on the reportserver. If specified, a human-readable version of the report will be saved in this directory, and it's path will be mentioned in the IRC notification. Don't forget to create the directory on your reportserver, writeable to the user running the puppet-master, and setup a job to clean old reports.
    * `report_url`: an URL, which if specified, will be appended to the IRC notification. Some special characters will be expanded to values found in the report. Example: `http://foreman.example.com/hosts/%h/reports/last`. Currently supported characters include:
      * `%c`: configuration version string
      * `%e`: puppet's run environment
      * `%h`: host name from the report
      * `%k`: kind of report
      * `%s`: report status
      * `%t`: report timestamp
      * `%v`: puppet version

4.  Enable pluginsync and reports on your master and clients in `puppet.conf`

        [master]
        report = true
        reports = irc
        pluginsync = true
        [agent]
        report = true
        pluginsync = true

5.  Run the Puppet client and sync the report as a plugin

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
