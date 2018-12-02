#!/usr/bin/awk -f

BEGIN {
  FS="[\"<>]"
} 

{
  id=substr(FILENAME, 6, 10)
}

/profileImage/ {
  a[id]=1; 
  b[id,"img"]=$5
}

/class="text-center/ {
  b[id,$7]=$9
}

END {
  print "data = {";
  for(i in a) {
    print "\""i"\": {";
    print "\tname: \"" substr(b[i,"Ad"],6) "\",";
    print "\tsurname: \"" substr(b[i,"Soyad"],6) "\",";
    print "\timg: \"" b[i,"img"] "\"},";
  }
  print "};"
}
