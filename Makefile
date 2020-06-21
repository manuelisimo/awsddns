PREFIX ?= /usr

all:
	@echo Run \'make install\' to install

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@mkdir -p $(DESTDIR)/etc
	@cp -p awsddns.sh $(DESTDIR)$(PREFIX)/bin/awsddns.sh
	@cp -p awsddns.conf $(DESTDIR)/etc/awsddns.conf
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/awsddns.sh

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/awsddns.sh
	@rm -rf $(DESTDIR)/etc/awsddns.conf
