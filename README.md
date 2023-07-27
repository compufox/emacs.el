# :writing_hand:​🦊 focksy emacs

## Installing 

1. clone the repo
2. run the setup script for your shell
3. start emacs

The setup scripts will backup your current emacs config and emacs.d directory (to `~/.emacs.bak` and `~/.emacs.d.bak`) before symlinking emacs.el to `~/.emacs`. It will then attempt to install any fonts inside the `fonts/` directory and refresh the font cache.

## NOTES
- If you are running on Windows, please ensure that `emacs` is in your path, as the `setup.ps1` script needs to run it to generate the `bootstrap.el` file.
- If you are running on macOS, the editor will respond to system theme changes.
This transition between light/dark mode themes is made smoother by using [emacs-plus](https://github.com/d12frosted/homebrew-emacs-plus).
If you are using a different version of emacs that does not have the appropriate patches applied, it will default to using a method involving making shell calls to the included applescript "CheckSystemTheme.scpt" file.
This will cause a "System Events" dialog popup asking for permission to continue.
- The fonts directory as provided is empty and the config itself specifies non-free fonts, so please make changes as-needed for your setup.
