.PHONY : all
all : llc.zip corporate.zip

llc.zip : llcallmst.csv llcallnam.csv llcallagt.csv llcallarp.csv llcallase.csv llcallold.csv llcallmgr.csv llcallser.csv
	zip $@ $^

corporate.zip : cdxallmst.csv cdxallnam.csv cdxallagt.csv cdxallarp.csv cdxallaon.csv cdxallstk.csv cdxalloth.csv
	zip $@ $^

%.csv : %.txt schemas/%.schema
	iconv -f ISO-8859-9 -t UTF-8 $< | \
            perl -pe 's/İ/[/g' | \
            perl -pe 's/¨/\]/g' | \
            perl -pe 's/¬/^/g' | \
            perl -pe 's/\x0//g' | \
            tail -n+2 | \
            sed '$$d' | \
            in2csv -f fixed -s $(word 2,$^) | \
            python scripts/to_datelike.py > $@

%.txt : %.zip
	unzip $<
	touch $@	

%.zip :
	torify -i wget --timeout=60 --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" https://www.ilsos.gov/data/bs/$@
