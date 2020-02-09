.DELETE_ON_ERROR:
	
YEAR=2019

define get_html
curl 'http://abs.istanbul.edu.tr/DersDegerlendirme/DersVeDegerlendirme/Detay?FKOgrenciID=$(1)' -K curl.ini -H '$(COOKIE)' -o HTML/$(2).html
sleep `jot -r 1 0.1 1.0  0.1`
endef

# Notice that `sleep` with non-integer argument is only valid in the Mac
# `jot -r` chooses 1 random number between 0.1 and 1.0 in steps of 0.1

TGT:=
include task.mk

all: $(TGT)
	echo done 

#HTML/0405150035.html:
#	$(call get_html, 0405150035, 526129)
	
JPG/%.jpg: HTML/%.html
	@echo $@
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
