Sources += gapminder_hiv.rmd gapminder_funs.R country_regions.csv gapminder_index.csv

push_pages: ${Sources}
	cp $< gh-pages
	cd gh-pages; git commit -am "auto-commit"; git push; cd ..
