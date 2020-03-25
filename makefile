
SPHINXBUILD   	= sphinx-build
BUILDDIR 		= _build
SPHINXOPTS    	=

html:
	if [ -d "git_src" ]; \
		then cd git_src; git pull; echo "updated git_src"; \
		else git clone https://github.com/SNL-WaterPower/WecOptTool.git git_src; echo "cloned git_src"; \
	fi
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) . $(BUILDDIR)
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)."

clean:
	rm -rf $(BUILDDIR)/*
