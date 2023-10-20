Automounting of an external USB disk
====================================

Add the following udev rule to `config.json`:
```
  "os": {
    "udevRules": {
        "66": "ACTION==\"add\", SUBSYSTEMS==\"usb\", SUBSYSTEM==\"block\", ENV{ID_FS_USAGE}==\"filesystem\", RUN{program}+=\"/usr/bin/systemd-mount --no-block --automount=yes --collect $devnode\i /run/mount/ext"\n"
    }
  }
```

The device will be automatically mounted under `/run/mount/ext`.
