#!/usr/bin/awk -f
BEGIN {
	FS="[< ]+"
	OFS="\t"
}

/Ad/ {name= $7; next}
/Soyad/ {surname = $7; next}
/Kayıt Tarihi/ {tarihi = $8; next}
/Akademik Dönem/ {donem = $8; next}
/Müfredat Yılı/ {muf = $8; next}
/Geliş Şekli/ {split($0,a,"[:<]"); gelis=a[5]; next}
/Statü/ {split($0,a,"[:<]"); status=a[5]; next}
/EMail/ {email=$7; next}
/Cep Tel/ {
	split(FILENAME,a,"[/.]")
	print a[2],email,$7,name" "surname,tarihi,donem,muf,gelis,status
}
