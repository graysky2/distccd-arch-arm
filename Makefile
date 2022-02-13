PREFIX ?= /usr
INITDIR = $(PREFIX)/lib/systemd/system
CONFDIR = /etc/conf.d

RM = rm
SED = sed
INSTALL = install -p
INSTALL_DATA = $(INSTALL) -m644
INSTALL_DIR = $(INSTALL) -d
Q = @

install-common:
	$(INSTALL_DIR) "$(DESTDIR)$(CONFDIR)"
	$(INSTALL_DATA) common/distccd-armv7h "$(DESTDIR)$(CONFDIR)/distccd-armv7h"
	$(INSTALL_DATA) common/distccd-armv8  "$(DESTDIR)$(CONFDIR)/distccd-armv8"

install-init:
	$(INSTALL_DIR) "$(DESTDIR)$(INITDIR)"
	$(INSTALL_DATA) init/distccd-armv7h.service "$(DESTDIR)$(INITDIR)/distccd-armv7h.service"
	$(INSTALL_DATA) init/distccd-armv8.service "$(DESTDIR)$(INITDIR)/distccd-armv8.service"

uninstall:
	$(RM) "$(DESTDIR)$(CONFDIR)/distccd-armv7h"
	$(RM) "$(DESTDIR)$(CONFDIR)/distccd-armv8"
	$(RM) "$(DESTDIR)$(INITDIR)/distccd-armv7h.service"
	$(RM) "$(DESTDIR)$(INITDIR)/distccd-armv8.service"

install: install-common install-init

.PHONY: install-common install-init uninstall
