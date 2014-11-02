Install
$ git clone https://github.com/AxelTB/awesome-configs.git ~/.config/awesome && cd ~/.config/awesome && git submodule init && git submodule update

Debian (Jessie or latest)
1. Download the >3.5 version from here https://packages.debian.org/search?keywords=awesome (As I write is under "rc-buggy")
2. # dpkg -i dpkg -i awesome_[version]_[arch].deb
3. # apt-get -f install
4. # apt-get install awesome-extra lm-sensors


Require:
* sensors
* "en_US.UTF-8" localization available (If the system default is diferent)
* awesome > 3.5

Version for Gnome

To use gnome-session work create the file /usr/share/gnome-session/sessions/awesome.session

[GNOME Session]
Name=Awesome session
RequiredComponents=gnome-settings-daemon;
RequiredProviders=windowmanager;notifications;
DefaultProvider-windowmanager=awesome
DefaultProvider-notifications=notification-daemon

Then create the file persona.lua and add the line
run_once("gnome-session --session=awesome")