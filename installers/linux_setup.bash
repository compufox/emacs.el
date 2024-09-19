#!/bin/env bash
FONT_DIR="~/.fonts"
SERVICE_FILE="emacs-user-systemd.service"
SERVICE_LOCATION="~/.config/systemd/user"
SERVICE_ACTIVATION_README="Activate service by running: systemd --user enable $SERVICE_FILE"

if [ "$(basename $PWD)" == "installers" ] ; then
    cd ..
fi

if [ "$(uname)" == "Darwin" ] ; then
    FONT_DIR = "~/Library/Fonts"
    SERVICE_FILE = "emacs-macos-launchagent.plist"
    SERVICE_LOCATION = "~/Library/LaunchAgents"
    SERVICE_ACTIVATION_README = "Activate service by running: launchctl bootup $SERVICE_LOCATION/$SERVICE_FILE"
fi

if [ ! -d $FONT_DIR ] ; then
    mkdir $FONT_DIR
fi

[[ -f ~/.emacs ]] && mv ~/.emacs ~/.emacs.bak
[[ -d ~/.emacs.d ]] && mv ~/.emacs.d ~/.emacs.d.bak

echo "Making link..."
ln -sf $(pwd)/bootstrap.el ~/.emacs

## Commenting this out for now
#echo "Installing git hooks..."
#cp hooks/* .git/hooks/
#chmod +x .git/hooks/*

echo "Installing fonts..."
find -E fonts -type f -regex ".*\.(otf|ttf)" -exec cp \{\} $FONT_DIR \;
fc-cache -v 

echo "Touching local.el file"
touch local.el

echo "Install service to run Emacs as a daemon on login? (y/N) "
read response

if [ "$response" == "y" ] ; then
    mkdir -p $SERVICE_LOCATION
    ln -sf $(pwd)/extras/"$SERVICE_FILE" "$SERVICE_LOCATION/$SERVICE_FILE"

    echo $SERVICE_ACTIVATION_README
fi
