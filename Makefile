.DELETE_ON_ERROR:
	
YEAR=2019
SEM=2
TGT:=
COURSES:=
SRC:=~/Blog/_priv/2020
DST:=~/Web/site/attend
HTML:=HTML
JPG:=JPG

all: targets

include cookie.mk
include $(YEAR)/$(SEM)/courses.mk
# include $(YEAR)/$(SEM)/task.mk

courses: $(COURSES)
	echo $(COURSES)

$(YEAR)/$(SEM)/task.mk: $(COURSES)
	@jq -r '.Data[]|[.Numara, .ogrKimlikID]|@tsv' $^ | grep -v '^\t' | \
	awk -F "\t" '{print "$$(HTML)/"$$1".html:\n\t@echo $$@\n\t$$(call get_html,"$$2","$$1")"; \
	print "\nTGT+= $$(HTML)/"$$1".html $$(JPG)/"$$1".jpg\n"}' > $@

targets: $(TGT)

# 	@./parse_json.py $^ | cut -f 1-5|sort -u| awk -f tsv2make.awk > $@

# To download the image we need to parse the HTML file. AWK produces the CURL
# command, which works without Cookie. The command is executed immediately
$(JPG)/%.jpg: $(HTML)/%.html
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk -v OUTFILE=$@ -f get_jpeg.awk $^ | sh

emails.txt: $(wildcard $(HTML)/*)
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk -f get_emails.awk $^ > $@

rfid-students-new.json: $(wildcard $(SRC)/*/attendance/20*.txt)
	@awk 'NF<=3 {a[$$2]=$$1; next} \
	END {print "ids={"; for(i in a) print "\""i"\" : \""a[i]"\","; \
		print "};"}' $^ > $@

rfid-students.txt: $(wildcard $(SRC)/*/attendance/20*.txt)
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk -F "\t" 'NF==2 {a[$$1]=$$2; next} /st_number/ {next} \
		/\?\?\?\?/ {next} a[$$2]!=$$1 {a[$$2]=$$1} \
		END {for(i in a) print i"\t"a[i]}' $@ $^ | sort > rfid-students.tmp
	@mv rfid-students.tmp $@

rfid-students.json: rfid-students.txt
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk 'BEGIN {print "ids = {"} \
		{print "\""$$1"\" : \""$$2"\","} \
		END {print "};"}' $^ > $@

data-students.json: $(wildcard $(HTML)/*)
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk -f parseHTML.awk $^ > $@

extra.txt: /Users/anaraven/Downloads/WelcomesurveyCMB22020.csv /Users/anaraven/Downloads/PeerReview1.csv
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk -F, 'BEGIN {OFS="\t"} \
		FILENAME==ARGV[1] && FNR>1 {msg[$$3]+="Survey OK "} \
		FILENAME==ARGV[2] && FNR>1 && NF>10 {msg[$$3]+="HW2 OK"} \
		END {for(i in msg){print i,msg[i]}}' $^ > $@

extra.js: extra.txt
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk -F"\t" 'BEGIN {print "extra = {"} \
		{print $$1,": \""$$2"\","} \
		END {print "};"}' "$^" > $@

$(YEAR)/$(SEM)/all_courses.json: cookie.mk
	@date "+%Y-%m-%d %H:%M:%S $@"
	@curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/GetTanimliDersler' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36' -H 'Referer: http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/Index' -H 'DNT: 1' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,es;q=0.8,fr;q=0.7' -H '$(COOKIE)' --data 'sort=&page=1&pageSize=50&group=Birim-asc&filter=&yil=$(YEAR)&donem=$(SEM)' --compressed -o $@

courses.txt: $(YEAR)/$(SEM)/courses.txt

$(YEAR)/$(SEM)/courses.txt: $(YEAR)/$(SEM)/all_courses.json
	@date "+%Y-%m-%d %H:%M:%S $@"
	@jq -r '.Data[].Items[] | [.DersKodu, .DersEID, .BirimID, .DersAdi] |@tsv' $^ > $@

# Course filename is YEAR/SEMESTER/CODE-DEPARTMENT
$(YEAR)/$(SEM)/courses.mk: $(YEAR)/$(SEM)/courses.txt
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk -F"\t" '{print "$(YEAR)/$(SEM)/"$$1"-"$$3".json: cookie.mk\n\t@echo $$@\n\t@$$(call get_course,"$$2")"; \
		print "\nCOURSES+= $(YEAR)/$(SEM)/"$$1"-"$$3".json\n"}' $^ > $@

define get_course
curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/GetDersiAlanOgrenciler' -H 'Referer: http://abs.istanbul.edu.tr/DersDegerlendirme/DersiAlanOgrenciListesi/DersiAlanOgrenciler?dersGrupEID=$(1)' -H '$(COOKIE)' -K curl.ini --data 'sort=&group=&filter=&dersGrupEID=$(1)' -o $@
sleep `jot -r 1 0.1 1.0  0.1`
endef

define get_html
curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersVeDegerlendirme/Detay?FKOgrenciID=$(1)' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36' -H 'DNT: 1' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9,es;q=0.8,fr;q=0.7' -H '$(COOKIE)' --compressed -o $(HTML)/$(2).html
sleep `jot -r 1 0.1 1.0  0.1`
endef
# Notice that `sleep` with non-integer argument is only valid in the Mac
# `jot -r` chooses 1 random number between 0.1 and 1.0 in steps of 0.1
#


page: $(DST)/index.html
	@date "+%Y-%m-%d %H:%M:%S $@"

$(DST)/index.html: index.html data-students.json rfid-students.json extra.js
	@date "+%Y-%m-%d %H:%M:%S $@"
	@awk '/data-students.json/ {print "<script>"; \
		while(getline<"data-students.json") {print} \
		while(getline<"extra.js") {print} print "</script>"; next} \
	     /rfid-students.json/ {print "<script>"; \
	        while(getline<"rfid-students.json") {print} print "</script>"; next} \
	     {print}' $< > $@
