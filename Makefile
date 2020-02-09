.DELETE_ON_ERROR:
	
YEAR=2019
SEM=2

all: targets

include cookie.mk

define get_html
curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersVeDegerlendirme/Detay?FKOgrenciID=$(1)' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36' -H 'DNT: 1' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,es;q=0.8,fr;q=0.7' -H '$(COOKIE)' --compressed -o HTML/$(2).html
sleep `jot -r 1 0.1 1.0  0.1`
endef
# Notice that `sleep` with non-integer argument is only valid in the Mac
# `jot -r` chooses 1 random number between 0.1 and 1.0 in steps of 0.1

TGT:=
include task.mk

targets: $(TGT)

# To download the image we need to parse the HTML file. AWK produces the CURL
# command, which works without Cookie. The command is executed immediately
JPG/%.jpg: HTML/%.html
	@echo $@
	@awk -v OUTFILE=$@ -f get_jpeg.awk $^ | sh

task.mk: $(wildcard $(YEAR)/$(SEM)/M*)
	@jq -r '.Data[]|[.Numara, .ogrKimlikID]|@tsv' $^ | grep -v '^\t' | \
	awk -F "\t" '{print "HTML/"$$1".html:\n\t$$(call get_html,"$$2","$$1")"; \
	print "\nTGT+= HTML/"$$1".html JPG/"$$1".jpg\n"}' > $@

# 	@./parse_json.py $^ | cut -f 1-5|sort -u| awk -f tsv2make.awk > $@

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

$(YEAR)/$(SEM)/all_courses.json: cookie.mk
	curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/GetTanimliDersler' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36' -H 'Referer: http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/Index' -H 'DNT: 1' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,es;q=0.8,fr;q=0.7' -H '$(COOKIE)' --data 'sort=&page=1&pageSize=50&group=Birim-asc&filter=&yil=$(YEAR)&donem=$(SEM)' --compressed -o $@

courses.txt: $(YEAR)/$(SEM)/all_courses.json
	@jq -r '.Data[].Items[] | [.DersKodu, .DersEID, .DersAdi] |@tsv' $^ > $@

courses.mk: courses.txt
	awk -F"\t" '{print "$$(YEAR)/$$(SEM)/"$$1".json:\n\t$$(call get_course,"$$2")"; \
		print "\nTGT2+= $$(YEAR)/$$(SEM)/"$$1".json\n"}' $^ > $@

define get_course
curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/GetDersiAlanOgrenciler' -H 'Referer: http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/DersiAlanOgrenciler?dersGrupEID=$(1)' -H '$(COOKIE)' -K curl.ini --data 'sort=&group=&filter=&dersGrupEID=$(1) -o $@' 
sleep `jot -r 1 0.1 1.0  0.1`
endef

courses: $(TGT2)
