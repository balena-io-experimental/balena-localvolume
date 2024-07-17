## Automounting of an external drive
====================================

In order to mount a USB or NVMe drive into containers, we first need to setup a `udev` rule in balenaOS. This rule needs to be added to the device `config.json` before flashing the device or manually via an ssh connection to the hostOS.

Add the following udev rule to `config.json`:
```
  "os": {
    "udevRules": {
      "66": "ACTION==\"add\", SUBSYSTEMS==\"usb\", SUBSYSTEM==\"block\", ENV{ID_FS_USAGE}==\"filesystem\", RUN{program}+=\"/usr/bin/systemd-mount --no-block --automount=yes --bind-device --options=noexec,nosuid,nodev,sync --collect $devnode /run/mount/ext\"\n"
      "67": "ACTION==\"add\", SUBSYSTEMS==\"nvme\", KERNEL==\"nvme[0-9]n[0-9]\", ENV{ID_FS_USAGE}==\"filesystem\", RUN{program}+=\"/usr/bin/systemd-mount --no-block --automount=yes --bind-device --options=noexec,nosuid,nodev,sync --collect $devnode /run/mount/ext\"\n"
    }
  },
```
Rule `66` is for USB and `67` is for NVMe drives, you only need to include the rule for the drive type you want to support.

Once you have added the rules, reboot the device. Now anytime an external USB or NVMe drive is plugged in, the rule will automatically mount that drive under `/run/mount/ext`.

## Make the drive available to containers

Now in order to make the drive available to containers we need to create a volume that bind-mounts the location in `/run` to a named volume in our composition. To do this we add the following to our compose.yaml:
```
volumes:
  test-volume:
    driver: local
    driver_opts:
      type: none
      o: bind,rshared
      device: /run/mount
```

This will create a named volume called `test-volume` that is mounted to the host `/run/mount/` directory. 

**WARNING!!! :** It is not supported to mount anything outside of `/run/mount` for now as balenaOS makes no guarentees that those files and directories will exist in future versions.  

Once we have the named volume, we can use it in any of our container services with the usual named volume syntax, like this:
```
services:
  app1:
    build:
      context: ./app1
    volumes:
      - 'test-volume:/data'
  app2:
    image: my-image
    volumes:
      - 'test-volume:/app'
```