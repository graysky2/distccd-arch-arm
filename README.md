# distccd-arch-arm
Provides an Arch ARM client with Systemd services/environment files to make use of [distcc-alarm](https://aur.archlinux.org/packages/distccd-alarm-armv7h/) naively.

## Dependencies for Arch ARM client
* distcc
* devtools-alarm (not strictly needed but highly recommended)

## Dependencies for volunteers (usually x86_64)
* [distcc-alarm](https://aur.archlinux.org/packages/distccd-alarm-armv7h/)

## Installation
* To build from source, see the included INSTALL file.
* ![logo](http://www.monitorix.org/imgs/archlinux.png "arch logo") Arch ARM users can build from [this](https://aur.archlinux.org/packages/distccd-alarm-armv7h/) package in the [AUR](https://aur.archlinux.org/).

## Usage examples
The examples below are a bit wider in scope than this software but can be useful/informative. They detail how to compile using a clean-chroot on Arch ARM distributing out via distcc. For my own use, I build on a RPi4 client with a single x86_64 volunteer. On the volunteer, I export via NFS the space where the build root resides. If this appeals to you, see [this script](https://github.com/graysky2/bin/blob/master/arm-build) I use to automate building. Alternatively, can you use the instructions below.  Note that in the script, you'll need to change a few lines to match your setup but it should serve as a good template.

### Notes
Support for armv5 and armv6h has been reomved upstream. I will edit this at some point.

I just show armv7h and armv6h here but you can apply these to armv5 and armv8 rather easily.  Just remember:
* If running a firewall, traffic to the correct tcp port on each box (3633-3636) for armv5-armv8 respectively must be allowed.
* On a box running armv7, you can build armv6 and armv7.
* On a box running armv8, you can only build armv8.
* I never actually built for armv5 so I do not know if a box running armv7h can build it or not.

### Building armv7h on armv7h using an x86_64 volunteer
#### On the Arch x86_64 volunteer
* Ensure the firewall is allowing tcp/3635.
* Start `distccd-armv7h`

#### On the Arch ARM client
* Ensure the firewall is allowing tcp/3635.
* Start `distccd-armv7h` service.

To create an armv7h build root:
```
$ mkdir /home/facade/armv7h
$ mkarchroot -C /etc/pacman.conf -c /var/cache/pacman/pkg /home/facade/armv7h/root base-devel distcc
```
Depending on how you defined pacman mirrors in `/etc/pacman.conf` you may need to copy `/etc/pacman.d/mirrorlist` into the build root.
```
# cp /etc/pacman.d/mirrorlist /home/facade/armv7h/root/etc/pacman.d/
```

* Edit `/home/facade/armv7h/root/etc/makepkg.conf` to:
* Define the number of MAKEFLAGS (alternatively you can prefix the call to `makechrootpkg` with an alternative value, see below)
* Enable distcc (In the BUILDENV array)
* Define DISTCC_HOSTS (at a minimum enter the IP:port of the volunteer, for example `192.168.1.102:3635`)

If you already have created a build root, and want to update it:
```
$ arch-nspawn -C /etc/pacman.conf -c /var/cache/pacman/pkg /home/facade/armv7h/root pacman -Syu --noconfirm"
```
* Enter the directory containing the PKGBUILD/files to build and run this command:
```
$ makechrootpkg -C /var/cache/pacman/pkg -r /home/facade/armv7h
```
 
The package should build and distribute (if applicable) via distccd to the volunteer.

Note that you can optionally pass variables such as `MAKEFLAGS=` thus overriding the value in the buildroot's `makepkg.conf` to the command by prefixing it like this:
```
$ MAKEFLAGS=16 makechrootpkg -C /var/cache/pacman/pkg -r /home/facade/armv7h
```

### Building armv6h on armv7h using an x86_64 volunteer
This is nearly identical to building armv7h on armv7h shown above with a few caveats.

#### On the Arch x86_64 volunteer
* Ensure the firewall is allowing tcp/3634.
* Start `distccd-armv6h`

#### On the Arch ARM client
* Use the corresponding `distccd-armv6h*` files and note that the port number is tcp/3634.
* The pacman.conf will need to be modified to support armv6h. It's enough to just replace the Architecture to a temp pacman.conf which I show below. I also recommend creating a separate package cache directory to avoid signature problems when building both armv7h and armv6h, so creating the armv6h build root becomes:
```
# mkdir /var/cache/pacman/pkg6
$ mkdir /home/facade/armv6h
$ sed -e '/Architecture =/ s,7h,6h,' /etc/pacman.conf > /tmp/pac6.conf
$ mkarchroot -C /tmp/pac6.conf -c /var/cache/pacman/pkg6 /home/facade/armv6h/root base-devel distcc
```
* Once created, setup `/home/facade/armv6h/root/etc/makepkg.conf` as shown above.
* Enter the directory containing the PKGBUILD/files to build and run this command:
```
$ makechrootpkg -C /var/cache/pacman/pkg6 -r /home/facade/armv6h
```
