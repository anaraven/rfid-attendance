.DELETE_ON_ERROR:
	
YEAR=2019

define get_html
curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersVeDegerlendirme/Detay?FKOgrenciID=$(1)' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36' -H 'DNT: 1' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,es;q=0.8,fr;q=0.7' -H '$(COOKIE)' --compressed -o HTML/$(2).html
sleep 2
endef

TGT:=
include task.mk

all: $(TGT)
	echo done 

#HTML/0405150035.html:
#	$(call get_html, 0405150035, 526129)
	
JPG/%.jpg: HTML/%.html
	@awk -v OUTFILE=$@ -f get_jpeg.awk $^ | sh

task.mk: $(wildcard $(YEAR)/*)
	@./parse_json.py $^ | cut -f 1-5|sort -u| awk -f tsv2make.awk > $@
	
emails.txt: $(wildcard HTML/*)
	@awk -f get_emails.awk $^ > $@

rfid-students-new.json: $(wildcard $(SRC)/*/attendance/20*.txt)
	@awk 'NF<=3 {a[$$2]=$$1; next} \
	END {print "ids={"; for(i in a) print "\""i"\" : \""a[i]"\","; \
		print "};"}' $^ > $@

data-students.json: $(wildcard HTML/*)
	@awk -f parseHTML.awk $^ > $@

#HTML/%.html: bioinfo
#	grep $* cmb1 | awk -vCOOKIE="$(COOKIE)" -f ~/Web/blog/_code/attendance/get_html.awk 
