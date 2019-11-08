:: you wont be able to run this by double clicking because it executes without %CD% set properly
::  you'll also have to run this from an administrator console because cant link stuff as normal user :shrug:
mklink /D %APPDATA%\.emacs.d %CD%\emacs.d
mklink %APPDATA%\.emacs %CD%\emacs.el
