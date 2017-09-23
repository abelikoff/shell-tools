# Desktop tools

These are various tools to make desktop work more productive.

## wpgallery.sh

Change wallpaper picture periodically in a random fashion using images
from a directory provided. This is currently Gnome-centric (i.e. using
`gsettings`). I will probably make it more generic by using `feh`.

```
wpgallery.sh -h
```

To set it up to start automatically, create a file
`~/.config/autostart/wpgallery.desktop`:

```
[Desktop Entry]
Type=Application
Exec=<PATH_TO_FILE>/wpgallery.sh
Hidden=false
X-GNOME-Autostart-enabled=true
Name=wpgallery
Comment=Wallpaper changer
```

Pre-requisites:
* `bash`
* Gnome environment (or a derivative)
