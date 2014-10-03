Version for Gnome


To make gnome-session work create the file /usr/share/gnome-session/sessions/awesome.session


[GNOME Session]
Name=Awesome session
RequiredComponents=gnome-settings-daemon;
RequiredProviders=windowmanager;notifications;
DefaultProvider-windowmanager=awesome
DefaultProvider-notifications=notification-daemon
