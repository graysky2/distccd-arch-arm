# distccd-arm
Provides an Arch ARM client with Systemd services/environment files to make use of [distcc-alarm](https://aur.archlinux.org/packages/distccd-alarm-armv7h/) naively.

## Dependencie for Arch ARM client
- distcc
- devtools-alarm (not strictly needed but highly recommended)

## Dependencies for volunteers (usually x86_64)
- [distcc-alarm](https://aur.archlinux.org/packages/distccd-alarm-armv7h/)

## Usage example: building armv7h on armv7h using an x86_64 volunteer
### On the Arch x86_64 volunteer
- Ensure that the correct subnet is defined in `/etc/conf.d/distccd-armv7h` to allow connections.
- Ensure the firewall allowing tcp/3635.
- Start `distccd-armv7h`

### On the Arch ARM client
- Ensure that the correct subnet is defined in `/etc/conf.d/distccd-armv7h` to allow connections.
- Ensure the firewall allowing tcp/3635.
- Start `distccd-armv7h` service.

To create an armv7h build root:
```
$ mkdir /home/facade/armv7h
$ mkarchroot -C /etc/pacman.conf -c /var/cache/pacman/pkg /home/facade/armv7h/root base-devel distcc
```
Depending on how you defined pacman mirrors in `/etc/pacman.conf` you may need to copy `/etc/pacman.d/mirrorlist` into the build root.
```
# cp /etc/pacman.d/mirrorlist /home/facade/armv7h/root/etc/pacman.d/
```

- Edit `/home/facade/armv7h/root/etc/makepkg.conf` to:
- Define the number of MAKEFLAGS
- Enable distcc (In the BUILDENV array)
- Define DISTCC_HOSTS (at a minimum enter the IP:port of the volunteer, for example `192.168.1.102:3635`)

If you already have created a build root, and want to update it:
```
$ arch-nspawn -C /etc/pacman.conf -c /var/cache/pacman/pkg /home/facade/armv7h/root pacman -Syu --noconfirm"
```
- Enter the directory containing the PKGBUILD/files to build and run this command:
```
$ MAKEFLAGS=-j10 makechrootpkg -C /var/cache/pacman/pkg -r /home/facade/armv7h
```

The package should build and distrubute (if applicable) via distccd to the volunteer.

## Usage example: building armv6h on armv7h using an x86_64 volunteer
This is nearly identical to building armv7h on armv7h shown above with a few caveats.

### On the Arch x86_64 volunteer
- Ensure that the correct subnet is defined in `/etc/conf.d/distccd-armv6h` to allow connections.
- Ensure the firewall allowing tcp/3634.
- Start `distccd-armv6h`

### On the Arch ARM client
- Use the corresponding `distccd-armv6h*` files and note that the port number is tcp/3634.
- The pacman.conf will need to be modified to support armv6h. It's enough to just replace the Architecture to a temp pacman.conf which I show below. I also recommend creating a separate package cache directory to avoid signature problems when building both armv7h and armv6h, so creating the armv6h build root becomes:
```
# mkdir /var/cache/pacman/pkg6
$ mkdir /home/facade/armv6h
$ sed -e '/Architecture =/ s,7h,6h,' /etc/pacman.conf > /tmp/pac6.conf
$ mkarchroot -C /tmp/pac6.conf -c /var/cache/pacman/pkg6 /home/facade/armv6h/root base-devel distcc
```
- Once created, setup `/home/facade/armv6h/root/etc/makepkg.conf` as shown above.
- Enter the directory containing the PKGBUILD/files to build and run this command:
```
$ MAKEFLAGS=-j10 makechrootpkg -C /var/cache/pacman/pkg6 -r /home/facade/armv6h
```
