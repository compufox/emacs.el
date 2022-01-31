# Foxie Emacs config
## ava fox 

clone the repo using `git clone --recurse-submodules` and source the appropriate file for your shell
(see notes inside of SETUP.BAT for notes specific to running it on windows)

running the setup scripts will backup your current .emacs file and .emacs.d folder and symlink emacs.el into it's place.
it will also install any/all git hooks from the `hooks` subfolder into place as well as installing any fonts inside of the `fonts` subfolder

the fonts directory is empty (on purpose), and the config specifies certain fonts that are proprietary. Whoopsies.

we include use-package as a submodule because the entire config depends on it, and this prevents any issues that may arise from trying to install it during an initial load situation 
