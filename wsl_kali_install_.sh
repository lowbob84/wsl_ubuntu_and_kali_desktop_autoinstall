#!/bin/bash
# title                   : "wsl_kali_install.sh"
# description             : "Automatic install of wsl kali linux with gnome desktop"
# author                  : "Christopher Lange aka. lowbob84"
# git repository  		    : "https://github.com/lowbob84/"
# email                   : "chris@lowbob.de"
# date                    : 2023-12-11
# version                 : 1.0.0

# For updates and contributions, head over to
# git repository  		: "https://github.com/lowbob84/wsl_ubuntu_and_kali_desktop_autoinstall"

USER="$(grep 1000 /etc/passwd | awk -F: '{print $1}')"

cat <<EOF > "/etc/sudoers.d/${USER}"
${USER}  ALL=(ALL) NOPASSWD: ALL
EOF

## force apt ipv4
#sudo echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/90force-ipv4

apt-get update &&
apt-get upgrade -qq -y &&
apt-get install -qq -y net-tools bash-completion figlet

cat <<EOF > "/etc/wsl.conf"
[boot]
systemd=true

EOF

cat <<\EOF >> "/home/${USER}/.bashrc"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

export LIBGL_ALWAYS_INDIRECT=1
export DISPLAY=$(ip route list |grep default |awk '{print $3}'):0.0
export PULSE_SERVER=tcp:$(ip route list |grep default |awk '{print $3}')
EOF

cat <<\EOF >> "/home/${USER}/.profile"
export LIBGL_ALWAYS_INDIRECT=1
export DISPLAY=$(ip route list |grep default |awk '{print $3}'):0.0
export PULSE_SERVER=tcp:$(ip route list |grep default |awk '{print $3}')

if [ -f ~/.dbus_init ]; then
    . ~/.dbus_init
fi

if [ -f ~/.gnome_desktop_env ]; then
    . ~/.gnome_desktop_env
fi
EOF

cat <<EOF > "/home/${USER}/.gnome_desktop_env"
export XDG_CURRENT_DESKTOP=gnome
export XDG_SESSION_DESKTOP=gnome
export DESKTOP_SESSION=gnome
export GNOME_SHELL_SESSION_MODE=gnome

# X11 sessions
export XDG_CONFIG_DIRS=/etc/xdg/xdg-kali-purple:/etc/xdg
export XDG_DATA_DIRS=/usr/share/gnome:/usr/local/share/:/usr/share/
export XDG_MENU_PREFIX=gnome-

export XDG_SESSION_TYPE=x11
export XDG_SESSION_CLASS=user
export GDK_BACKEND=x11

# Disables using Direct3D in Mesa 3D graphics library
export LIBGL_ALWAYS_SOFTWARE=1
EOF

cat <<\EOF > "/home/${USER}/.dbus_init"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_RUNTIME2_DIR=/run/user/0
if [ ! -d "$XDG_RUNTIME_DIR" ]; then
{
    mkdir $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR && chown $(id -un):$(id -gn) $XDG_RUNTIME_DIR
    mkdir $XDG_RUNTIME_DIR2 && chmod 700 $XDG_RUNTIME_DIR2 && chown root:root $XDG_RUNTIME_DIR
    service dbus start
}
fi

set_session_dbus()
{
    local bus_file_path="$XDG_RUNTIME_DIR/bus"

    export DBUS_SESSION_BUS_ADDRESS=unix:path=$bus_file_path

    if [ ! -e "$bus_file_path" ]; then
    {
        /usr/bin/dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --nofork --nopidfile --syslog-only &
    }
    fi
}

set_session_dbus

EOF

cat <<EOF > "/etc/rc.local"
#!/bin/bash
mount -o rw,remount /tmp/.X11-unix/
chmod 1777 /tmp/.X11-unix
chmod o+rw /dev/dri/renderD128
/usr/libexec/at-spi-bus-launcher --launch-immediately &
EOF

cat <<\EOF > "/usr/local/bin/start_kali_desktop"
#!/bin/bash
if [ -z "$DISPLAY" ]; then
    echo "Error: DISPLAY environment variable is not set."
    exit
fi

gnome-session --session=gnome
EOF

chmod 755 "/usr/local/bin/start_kali_desktop"
cd "/home/${USER}"
chown "${USER}":"${USER}" .profile .gnome_desktop_env .dbus_init .bashrc
service dbus start &&

apt-mark hold acpid acpi-support modemmanager &&
apt-get install -y kali-desktop-gnome &&

systemctl disable dbus-org.freedesktop.network1.service &&
systemctl set-default multi-user.target &&
sudo -u "${USER}" settings set org.gnome.desktop.interface enable-animations false

N=5; while [[ $((--N)) >  0 ]]; do  echo -e "\033[2J\033[0m"; echo "Run start_kali_desktop after reboot in $N seconds" |  figlet -c && sleep 1 ; done