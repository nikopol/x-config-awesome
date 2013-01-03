my personal awesome config
==========================

vicious widget library included for a painless install
(see https://github.com/nikopol/x-config-awesome.git )

pretty easy to configure (see below)

![systray screenshot](https://github.com/nikopol/x-config-awesome/blob/master/systray.png?raw=true "sample systray screenshot")

"give it a try" install
--------------------
from your clone directory

	./install
	ln -s ~/.config/awesome/config.lua.default ~/.config/awesome/config.lua

permanent install
-----------------
from your clone directory

	mkdir -p $HOSTNAME/.config/awesome
	cp default/.config/awesome/config.lua.default $HOSTNAME/.config/awesome/config.lua
	#adapt conf to your box
	vim $HOSTNAME/.config/awesome/config.lua
	./install

(install will copy default/* to ~/* and $HOSTNAME/* to ~/*)
