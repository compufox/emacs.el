# Foxie Emacs config
## a. fox

clone the repo and source the appropriate file for your shell

running the setup scripts will backup your current .emacs file and .emacs.d folder and symlink emacs.el into it's place.
it will also install any/all git hooks from the `hooks` directory into place as well as installing any fonts inside of the `fonts` directory

the fonts directory is empty, and the config specifies non-free fonts. Oopsy-doodle.

the config is setup so as to bootstrap itself, so starting up emacs after a fresh clone should download and install everything as sepcified.
