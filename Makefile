foo :
	https://www.ilsos.gov/data/bs/llcallmst.zip

	https://www.ilsos.gov/data/bs/llcallnam.zip

	https://www.ilsos.gov/data/bs/llcallagt.zip

	https://www.ilsos.gov/data/bs/llcallarp.zip

	https://www.ilsos.gov/data/bs/llcallase.zip

	https://www.ilsos.gov/data/bs/llcallold.zip

	https://www.ilsos.gov/data/bs/llcallmgr.zip

	https://www.ilsos.gov/data/bs/llcallser.zip

csvs : mst.csv nam.csv agt.csv arp.csv ase.csv old.csv mgr.csv ser.csv

%.csv : llcall%.txt schemas/llcall%.schema
	cat $< | \
            perl -pe 's/\xDD/[/g' | \
            perl -pe 's/\xA8/\]/g' | \
            perl -pe 's/\xAC/^/g' | \
            tail -n+2 | \
            sed '$$d' | \
            in2csv -f fixed -s $(word 2,$^) > $@

%.txt : %.zip
	unzip $<
	touch $@	

%.zip :
	wget --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" https://www.ilsos.gov/data/bs/$@
