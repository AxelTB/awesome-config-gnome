Version for Gnome

Require:
* lm-sensors
* "en_US.UTF-8" localization (If the system default is diferent)


To make gnome-session work create the file /usr/share/gnome-session/sessions/awesome.session

[GNOME Session]
Name=Awesome session
RequiredComponents=gnome-settings-daemon;
RequiredProviders=windowmanager;notifications;
DefaultProvider-windowmanager=awesome
DefaultProvider-notifications=notification-daemon
