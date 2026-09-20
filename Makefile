default: clean export/web_release.zip

trim-whitespace:
	find -name '*.gd' | xargs sed -Ei 's/[ 	]+$$//'

export/web_release.zip: export/web/index.html
	zip --junk-paths -r $@ export/web/*

export/web/index.html:
	mkdir -p export/web
	godot --headless --export-release "Web" $@

clean:
	rm -rf export/web
	rm -f export/web_release.zip

build: export/web/index.html

.PHONY: clean build
