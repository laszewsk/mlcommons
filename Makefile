.PHONY: www

www:
	cd www; hugo

hugo: www

serve:
	cd www; hugo --config=config-local.toml serve

view:
	gopen http://localhost:1313

emacs:
	emacs www/content/en
