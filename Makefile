.PHONY: www


define banner
	@echo
	@echo "############################################################"
	@echo "# $(1) "
	@echo "############################################################"
endef

www:
	$(call banner, "hugo")
	cd www; hugo

hugo: www

serve:
	$(call banner, "SERVE")
	cd www; hugo --config=config-local.toml serve

view:
	$(call banner, "VIEW")
	gopen http://localhost:1313

emacs:
	$(call banner, "EMACS")
	emacs www/content/en

clean:
	$(call banner, "CLEAN")
	rm -rf *.zip
	rm -rf *.egg-info
	rm -rf *.eggs
	rm -rf docs/build
	rm -rf build
	rm -rf dist
	find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
	rm -rf .tox
