#!/usr/bin/awk -f

BEGIN {
	FS="\t"
}

{
	print "HTML/"$1".html:"
	print "\t$(call get_html,"$5","$1")"
	print "\nTGT+= HTML/"$1".html JPG/"$1".jpg\n"
}
