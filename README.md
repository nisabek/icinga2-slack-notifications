<!--
  Title: Icinga Slack Notifications
  Description: Icinga 2 notification integration with slack
  Author: nisabek richard.hauswald
  -->

# icinga2-slack-notifications
Icinga2 notification integration with slack

## Overview

Native, easy to use Icinga2 `NotificationCommand` to send Host and Service notifications to pre-configured Slack channel - with only 1 external dependency: `curl`

Also available on <a href="https://exchange.icinga.com/richardhauswald/icinga2-slack-notifications" target="_blank">Icinga2 exchange portal</a>

## What will I get?
* Awesome Slack notifications:

<p align="center">
  <img src="https://github.com/nisabek/icinga2-slack-notifications/raw/master/docs/Notification-Examples.png" width="600">
</p>

* Mobile Icinga monitoring alerts as well:

<p align="center">
  <img src="https://github.com/nisabek/icinga2-slack-notifications/raw/master/docs/Notification-Examples-mobile.png" width="400">
</p>

* Notifications inside Slack about your Host and Service state changes
* In case of failure get notified with the nicely-formatted output of the failing check
* Easy integration with Icinga2
* Only native Icinga2 features are used, no bash, perl, etc - keeps your server/virtual machine/docker instances small
* Debian ready-to-use package to reduce maintenance and automated installation effort
* Uses Lambdas!

## Why another approach?

We found the following 2 existing Icinga2 to Slack integrations. 

* https://github.com/spjmurray/slack-icinga2

  This plugin provides a polling interface towards Icinga2, giving the possibility to query the Icinga2 API and get information. 
  
  Since we cannot open our firewalls to enable access for slack servers to our Icinga2 instances, we need to
  have Icinga2 sending push notifications to Slack to report our Host and Service state changes.
* https://github.com/jjethwa/icinga2-slack-notification
  
  The plugin provides the possibility to send NotificationCommand to slack, however we found the following 
  downsides to be show stoppers for us:
   * Does not use Lambdas!
   * The Integration is time consuming and cumbersome
   * The author requires you to modify his source files in order to configure the slack webhook and channel. So we'd 
   have to configure everything again when we have to install an update of that integration.
   * No Debian package available, which leads to increased installation and maintenance effort.
   * Numerous bugs since the host output is not properly encoded:
     * as shell argument before it's passed to the shell script
     * as JSON before it's send to Slacks REST API

## Installation 

### Installation using Debian package

> !NOTE: At this moment debian package is behind the master code. If you want to use this plugin with Icinga Director, please make sure to install from Git (see below)
We're working on updating the repo in the meantime. 

We use [reprepro](https://mirrorer.alioth.debian.org/) to distribute our package from github.
You would need to install `apt-transport-https` that supports adding an `https` based repository to the debian repo list.

here are the steps to perform:

```
# apt-get install -y apt-transport-https
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 10779AB4
# add-apt-repository "deb https://raw.githubusercontent.com/nisabek/icinga2-slack-notifications/master/reprepro general main"
# apt-get update
```

You are now ready to install the plugin with 

```
# apt-get install icinga2-slack-notifications
```

This will create the plugin files in the correct `icinga2` conf directory. 

### Installation using git

1. Clone the repository and copy the relevant folder into your Icinga2 `/etc/icinga2/conf.d` directory
 
```
# git clone git@github.com:nisabek/icinga2-slack-notifications.git /opt/icinga2-slack-notifications
# cp -r /opt/icinga2-slack-notifications/src/slack-notifications /etc/icinga2/conf.d/
```

2. Use the `slack-notifications-user-configuration.conf.template` file as reference to configure your Slack Webhook URL and Icinga2 Base URL to create your own
 `slack-notifications-user-configuration.conf`
 
```
# cp /etc/icinga2/conf.d/slack-notifications/slack-notifications-user-configuration.conf.template /etc/icinga2/conf.d/slack-notifications/slack-notifications-user-configuration.conf
```
 
3. Fix permissions
 
```
# chown -R root:nagios /etc/icinga2/conf.d/slack-notifications
# chmod 0750 /etc/icinga2/conf.d/slack-notifications
# chmod 0640 /etc/icinga2/conf.d/slack-notifications/*
```

### Configuration 
 
#### Icinga2 features

In order for the slack-notifications to work you need at least the `checker`,  `command` and `notification` icinga2 features enabled.

In order to see the list of currently enabled features execute the following command

```
# icinga2 feature list
```

In order to enable a feature use 

```
# icinga2 feature enable FEATURE_NAME
```

#### Notification configuration

1. Configure Slack Webhook and Icinga2 web URLs in `/etc/icinga2/conf.d/slack-notifications/slack-notifications-user-configuration.conf`
```
template Notification "slack-notifications-user-configuration" {
    import "slack-notifications-default-configuration"

    vars.slack_notifications_webhook_url = "<YOUR SLACK WEBHOOK URL>, e.g. https://hooks.slack.com/services/TOKEN1/TOKEN2"
    vars.slack_notifications_icinga2_base_url = "<YOUR ICINGA2 BASE URL>, e.g. http://icinga-web.yourcompany.com/icingaweb2"
}
...
```

2. In order to enable the slack-notifications **for Services** add `vars.slack_notifications = "enabled"` to your Service template, e.g. in `/etc/icinga2/conf.d/templates.conf`

```
 template Service "generic-service" {
   max_check_attempts = 5
   check_interval = 1m
   retry_interval = 30s
 
   vars.slack_notifications = "enabled"
 }
 ```

In order to enable the slack-notifications **for Hosts** add `vars.slack_notifications = "enabled"` to your Host template, e.g. in `/etc/icinga2/conf.d/templates.conf`

```
 template Host "generic-host" {
   max_check_attempts = 5
   check_interval = 1m
   retry_interval = 30s
 
   vars.slack_notifications = "enabled"
 }
 ```

Make sure to restart icinga after the changes

```
# systemctl restart icinga2
```

2. Further customizations [_optional_]

You can customize the following parameters of slack-notifications :
  * slack_notifications_channel [Default: `#monitoring_alerts`]
  * slack_notifications_botname [Default: `icinga2`]
  * slack_notifications_plugin_output_max_length [Default: `3500`]
  * slack_notifications_icon_dictionary [Default:
   ```
     {
         "DOWNTIMEREMOVED" = "leftwards_arrow_with_hook",
         "ACKNOWLEDGEMENT" = "ballot_box_with_check",
         "PROBLEM" = "red_circle",
         "RECOVERY" = "large_blue_circle",
         "DOWNTIMESTART" = "arrow_up_small",
         "DOWNTIMEEND" = "arrow_down_small",
         "FLAPPINGSTART" = "small_red_triangle",
         "FLAPPINGEND" = "small_red_triangle_down",
         "CUSTOM" = "speaking_head_in_silhouette"
     }
   ```
  ]

In order to do so, place the desired parameter into `slack-notifications-user-configuration.conf` file.

Note 
> Objects as well as templates themselves can import an arbitrary number of other templates. Attributes inherited from a template can be overridden in the object if necessary.

The `slack-notifications-user-configuration` section applies to both Host and Service, whereas the 
`slack-notifications-user-configuration-hosts` and `slack-notifications-user-configuration-services` sections apply to Host and Service respectively


_Example channel name configuration for Service notifications_

``` 
template Notification "slack-notifications-user-configuration" {
    import "slack-notifications-default-configuration"

    vars.slack_notifications_webhook_url = "<YOUR SLACK WEBHOOK URL>, e.g. https://hooks.slack.com/services/TOKEN1/TOKEN2"
    vars.slack_notifications_icinga2_base_url = "<YOUR ICINGA2 BASE URL>, e.g. http://icinga-web.yourcompany.com/icingaweb2"
}

template Notification "slack-notifications-user-configuration-hosts" {
    import "slack-notifications-default-configuration-hosts"

    interval = 1m
}

template Notification "slack-notifications-user-configuration-services" {
    import "slack-notifications-default-configuration-services"

    interval = 3m
    
    vars.slack_notifications_channel = "#monitoring_alerts_for_service"
}
```

You can choose to override the whole icon dictionary, or override specific types only:

_Example override the whole icon dictionary_

```
template Notification "slack-notifications-user-configuration" {
    import "slack-notifications-default-configuration"

    vars.slack_notifications_webhook_url = "https://hooks.slack.com/services/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"
    vars.slack_notifications_icinga2_base_url = "http://localhost:80/icingaweb2"
    vars.slack_notifications_channel = "#icinga2-private-test"
    vars.slack_notifications_icon_dictionary = {
       "DOWNTIMEREMOVED" = "leftwards_arrow_with_hook",
       "ACKNOWLEDGEMENT" = "ballot_box_with_check",
       "PROBLEM" = "bomb",
       "RECOVERY" = "large_blue_circle",
       "DOWNTIMESTART" = "up",
       "DOWNTIMEEND" = "arrow_double_down",
       "FLAPPINGSTART" = "small_red_triangle",
       "FLAPPINGEND" = "small_red_triangle_down",
       "CUSTOM" = "speaking_head_in_silhouette"
    }    
    ...
```

_Example override specific type_

```
template Notification "slack-notifications-user-configuration" {
    import "slack-notifications-default-configuration"

    vars.slack_notifications_webhook_url = "https://hooks.slack.com/services/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"
    vars.slack_notifications_icinga2_base_url = "http://localhost:80/icingaweb2"
    vars.slack_notifications_channel = "#icinga2-private-test"

    vars.slack_notifications_icon_dictionary.CUSTOM = "cherries"
    ...
}
```

If you, for some reason, want to disable the slack-notifications from icinga2 change the following parameter inside the 
corresponding Host or Service configuration object/template:

`vars.slack_notifications == "disabled"`

Besides configuring the slack-notifications parameters you can also configure other Icinga2 specific configuration 
parameters of the Host and Service, e.g.:
* types
* user_groups
* interval
* period

## How it works
slack-notifications uses the icinga2 native [NotificationCommand] (https://docs.icinga.com/icinga2/latest/doc/module/icinga2/chapter/object-types#objecttype-notificationcommand) 
to collect the required data and send a message to configured slack channel using `curl`

The implementation can be found in `slack-notifications-command.conf` and it uses Lambdas!

## Testing

Since the official docker image of icinga2 seems not to be maintained, we've been using [jordan's icinga2 image](https://hub.docker.com/r/jordan/icinga2/)
to test the notifications manually.

Usual procedure for us to test the plugin is to 

* configure the `src/slack-notifications/slack-notifications-configuration.conf` file according to documentation
* configure a test `src/templates.conf` which contains the slack-notifications enabled for host and/or service
* run the `jordan/icinga2` with an empty volume at first
* copy the configurations to relevant directories
* restart the container

```
$ docker run -p 8081:80 --name slack-enabled-icinga2 -v $PWD/icinga2-docker-volume:/etc/icinga2 -idt jordan/icinga2:latest
$ docker cp src/templates.conf slack-enabled-icinga2:/etc/icinga2/conf.d/
$ docker cp src/slack-notifications slack-enabled-icinga2:/etc/icinga2/conf.d/
$ docker restart slack-enabled-icinga2
```

after that navigate to `http://localhost:8081/icingaweb2` and try out some notifications. 

We understand that this is far from automated testing, and we will be happy to any contributions that would improve the procedure.

## Troubleshooting
The slack-notifications command provides detailed debug logs. In order to see them, make sure the `debuglog` feature of icinga2 is enabled.

```
# icinga2 feature enable debuglog
```

After that you should see the logs in `/var/log/icinga2/debug.log` file. All the slack-notifications specific logs are pre-pended with "debug/slack-notifications"

Use the following grep for troubleshooting: 

```bash
$ grep "warning/PluginNotificationTask\|slack-notifications" /var/log/icinga2/debug.log
$ tail -f /var/log/icinga2/debug.log | grep "warning/PluginNotificationTask\|slack-notifications"
```

## Useful links
- [Setup Slack Webhook](https://api.slack.com/incoming-webhooks)
- [Enable Icinga2 Debug logging](https://docs.icinga.com/icinga2/latest/doc/module/icinga2/chapter/troubleshooting)
- [NotificationCommand of Icinga2](https://docs.icinga.com/icinga2/latest/doc/module/icinga2/toc#!/icinga2/latest/doc/module/icinga2/chapter/object-types#objecttype-notificationcommand)
- [Overriding template definitions of Icinga2](https://docs.icinga.com/icinga2/latest/doc/module/icinga2/toc#!/icinga2/latest/doc/module/icinga2/chapter/monitoring-basics#object-inheritance-using-templates)
- [Dockerized Icinga2](https://hub.docker.com/r/jordan/icinga2/)

## Running with Icinga Director

There has been some discussion [over here](https://github.com/nisabek/icinga2-slack-notifications/issues/5) on how to run the plugin with Icinga Director. We'd appreciate somebody going over this part of documentation and verifying it. 
 
Main points to make it work:

* Use the git version, not the debian package.
* Create a custom variable for slack_notifications as a string. 
* Run the kickstart wizard: https://github.com/nisabek/icinga2-slack-notifications/issues/5#issuecomment-369571754

### Latest how-to on Icinga Director

Thanks a lot to @jwhitbread for putting down these steps in the [issue](https://github.com/nisabek/icinga2-slack-notifications/issues/32)

* Use the git version, not the debian package.
* Add all three files into your global_templates directory e.g /etc/icinga2/zones.d/global_templates/. (I believe these can also be put into your director/master directory)
* Follow the above tutorial with editing said files and permissions.
* Add the vars.slack_notifications = "enabled" to the relevant templates or directly to the host/service objects.
* Restart icinga2 - systemctl restart icinga2.
* Navigate over to your icinga web interface > Icinga director on the left > Deployments
* This should notify you that you have a change, click deploy. If it doesn't then on the same page navigate to Render config > Deploy anyways.
* Check the console output of the deployment, green tick = good! Go double check your hosts and services are picking up the new variable and then give it a test!
