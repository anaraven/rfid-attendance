#!/usr/bin/awk -f
BEGIN {
	FS="[< ]+"
	OFS="\t"
}

{
	gsub("&#199;","Ç")
	gsub("&#220;","Ü")
	gsub("&#214;","Ö")
	gsub("&#231;","ç")
	gsub("&#252;","Ü")
	gsub("&#246;","Ö")
}

/Ad/ {name= $7;	gsub(/^ */,"", name); next}
/Soyad/ {surname = $7;	gsub(/^ */,"", surname); next}
/Kayıt Tarihi/ {tarihi = $8; next}
/Akademik Dönem/ {donem = $8; next}
/Müfredat Yılı/ {muf = $8; next}
/Geliş Şekli/ {split($0,a,"[:<]"); gelis=a[5]; gsub(/^ */,"", gelis); next}
/Statü/ {split($0,a,"[:<]"); status=a[5];	gsub(/^ */,"", status); next}
/EMail/ {email=$7; next}
/Cep Tel/ {
	cep=$8
	split(FILENAME,a,"[/.]")
	gsub(/^[ :]*/,"", cep)
	print a[2],cep,name" "surname,tarihi,donem,muf,gelis,status,email
}
