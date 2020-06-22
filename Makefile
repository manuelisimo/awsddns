PREFIX ?= /usr

all:
	@echo Run \'make install\' to install

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@mkdir -p $(DESTDIR)/etc
	@mkdir -p $(DESTDIR)/lib/dhcpcd/dhcpcd-hooks
	@cp -p awsddns.sh $(DESTDIR)$(PREFIX)/bin/awsddns.sh
	@cp -p awsddns.conf $(DESTDIR)/etc/awsddns.conf
	@cp -p 50-awsddns $(DESTDIR)/lib/dhcpcd/dhcpcd-hooks/50-awsddns
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/awsddns.sh
	@chmod 755 $(DESTDIR)/lib/dhcpcd/dhcpcd-hooks/50-awsddns

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/awsddns.sh
	@rm -rf $(DESTDIR)/etc/awsddns.conf
	@rm -rf $(DESTDIR)/lib/dhcpcd/dhcpcd-hooks/50-awsddns
