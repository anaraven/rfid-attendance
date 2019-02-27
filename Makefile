.DELETE_ON_ERROR:
	
rfid-students-new.json: $(wildcard $(SRC)/*/attendance/20*.txt)
	@awk 'NF<=3 {a[$$2]=$$1; next} \
	END {print "ids={"; for(i in a) print "\""i"\" : \""a[i]"\","; \
		print "};"}' $^ > $@

data-students.json: $(wildcard HTML/*)
	@awk -f parseHTML.awk $^ > $@
