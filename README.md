# This will become a Switchboard Plug for the Community Indictors Project.

<p align="center"><img src="screenshot-switchboard.png"/> </p>

<h1>Description:</h1>
This is a Switchboard 8 plug for Pantheon 8.1 that lets you change settings for <a href="https://github.com/MvBonin/wingpanel-community-indicators">wingpanel-community-indicators</a>.
It uses GTK4 and the XDG configuration directory, so it does not depend on X11 and is compatible with Wayland sessions.

It is still work in progress but some stuff works (if not yet so pretty).



<h2>Dependencies:</h2>
<pre>sudo apt-get install valac gcc meson libappstream-dev libjson-glib-dev libgee-0.8-dev libgtk-4-dev libswitchboard-3-dev</pre/>

<h2>Fedora</h2>
Install the Fedora build dependencies:
<pre>sudo dnf install gcc gcc-c++ meson ninja-build vala pkgconf-pkg-config \
  appstream-devel json-glib-devel libgee-devel gtk4-devel \
  libadwaita-devel granite-devel sassc</pre>

Fedora does not ship the Pantheon Switchboard development library in the
default repositories. Build and install Switchboard 8.0.3 first:
<pre>git clone --branch 8.0.3 --depth 1 https://github.com/elementary/switchboard.git
meson setup switchboard/build switchboard --prefix=/usr
meson compile -C switchboard/build
sudo meson install -C switchboard/build</pre>

Then build and install this plug:
<pre>meson setup build --prefix=/usr
meson compile -C build
sudo meson install -C build</pre>

<h2>Easy Installation</h2>
Download .deb file and install it via
<pre>sudo apt install ./FILENAME.deb</pre>

<h2>Build with meson</h2>
Open a Terminal in the extracted folder, build your application with meson and install it with ninja:<br/>

<pre>meson build --prefix=/usr
cd build
ninja
sudo ninja install
</pre>

<h2>Uninstall</h2>
Open a terminal in the build folder.
<pre>sudo ninja uninstall</pre>
