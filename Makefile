.PHONY : all
all : llc.zip corporate.zip

corporate.db :  cdxallmst.csv cdxallnam.csv cdxallagt.csv cdxallarp.csv cdxallaon.csv cdxallstk.csv cdxalloth.csv
	csvs-to-sqlite $^ $@
	sqlite-utils rename-table $@ cdxallmst master
	sqlite-utils rename-table $@ cdxallagt agent
	sqlite-utils rename-table $@ cdxallarp annual_report
	sqlite-utils rename-table $@ cdxallaon assumed_other_name
	sqlite-utils rename-table $@ cdxallstk stock
	sqlite-utils rename-table $@ cdxalloth other
	sqlite-utils transform $@ master --pk file_number
	sqlite-utils add-column $@ master name text
	sqlite3 $@ < scripts/add_name.sql


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
	@curl \
            --user $(ZYTE_API_KEY): \
            --header 'Content-Type: application/json' \
            --data '{"url": "https://www.ilsos.gov/data/bs/$@", "httpResponseBody": true}' \
            --compressed \
            https://api.zyte.com/v1/extract | \
            jq --raw-output .httpResponseBody | \
            base64 --decode > $@

wget --timeout=60 --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:106.0) Gecko/20100101 Firefox/106.0" https://www.ilsos.gov/data/bs/$@
