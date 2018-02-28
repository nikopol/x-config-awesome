# my awesome wm config

for awesome v4.x

## sample install
```bash
git clone git@github.com:nikopol/x-config-awesome.git
#backup previous user conf
[ -d ~/.config/awesome ] && mv ~/.config/awesome ~/.config/awesome.old
#link
ln -sf x-config-awesome ~/.config/awesome
#copy sample conf and adapt it to your system
cp x-config-awesome/conf-sample.lua x-config-awesome/conf.lua
vim x-config-awesome/conf.lua
#restart awesome (usually Mod+Ctrl+R)
```
