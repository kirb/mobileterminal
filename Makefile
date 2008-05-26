BUILDDIR	= ./build
SOURCEDIR	= .
APPNAME   = Terminal
APPDIR		= ./$(APPNAME).app

all: copySources depend Terminal package sendToiPod killOniPod done

svnversion:
	$(shell python ./Sources/Misc/svnversion.py)

copySources:
	@echo ... copying sources ...
	$(shell mkdir -p $(BUILDDIR))
	$(shell rm -f $(BUILDDIR)/Makefile)
	$(shell cp -p ./Makefile.build $(BUILDDIR)/Makefile)
	$(shell find $(SOURCEDIR) \( -name "*.m" -or -name "*.h" \) -type f \! -path "./build/*" -exec cp -p -f {} $(BUILDDIR) \;)

depend:
	@echo ... updating dependencies ...
	$(shell make -C $(BUILDDIR) depend)

Terminal:
	@echo ... building $(APPNAME) ...
	make -C $(BUILDDIR) $(APPNAME)

package:
	@echo ... packaging $(APPNAME).app ...
	$(shell rm -fr $(APPDIR))
	$(shell mkdir -p $(APPDIR))
	$(shell cp $(BUILDDIR)/$(APPNAME) $(APPDIR)/)
	$(shell cp Info.plist $(APPDIR)/Info.plist)
	$(shell cp -r ./Resources/* $(APPDIR)/)
	$(shell find $(APPDIR) -name ".svn" | xargs rm -Rf)

sendToiPod:
	@echo ... sending to iPod ...
	scp -r $(APPDIR) root@$(IPHONE_IP):/Applications/
	
killOniPod:
	@echo ... killing $(APPNAME) on iPod ...
	$(shell ssh root@$(IPHONE_IP) killall $(APPNAME))

startOniPod:
	@echo ... starting $(APPNAME) on iPod ...
	ssh root@$(IPHONE_IP) /Applications/$(APPNAME).app/$(APPNAME) ls

removeSources:
	@echo ... removing sources ...
	$(shell rm -f $(BUILDDIR)/*.c $(BUILDDIR)/*.h $(BUILDDIR)/*.m)

clean:
	@echo ... cleaning up ...
	rm -fr $(BUILDDIR)
	rm -fr *.o $(APPNAME).app $(APPNAME).zip
	rm -f svnversion.h

dist: svnversion copySources depend Terminal package
	zip -r $(APPNAME).zip $(APPDIR)
	python -c "v='`svnversion`'; v=v.find(':')!=-1 and v.split(':')[1] or v;cmd='mv Terminal.zip Terminal-'+v.rstrip('MS')+'.zip'; import os; os.system(cmd)"

done:
	@echo ... done

