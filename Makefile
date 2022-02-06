.PHONY: www

www:
	cd www; hugo

serve:
	cd www; hugo --config=config-local.toml serve

view:
	gopen http://localhost:1313
