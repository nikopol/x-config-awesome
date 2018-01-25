# my awesome wm config

for awesome v4.x

## sample install
```bash
git clone git@github.com:nikopol/x-config-awesome.git
#adapt conf to your system
vim x-config-awesome/conf.lua
#backup previous user conf
[ -d ~/.config/awesome ] && mv ~/.config/awesome ~/.config/awesome.old
#link
ln -sf x-config-awesome ~/.config/awesome
#restart awesome (usually Mod+Ctrl+R)
```