#!/usr/bin/perl 
use POSIX qw/strftime/;
$home="/home/ubuntu/scripts/doc_env";
$html="/usr/local/tomcat/";
$delimitor = "|";
#####Time Logic
  # usage: days_ago n
  # where n = number of days before today
        # take 86400 * # of days from right now in epoch seconds
                 $yestertime = time - (86400 * $in);
                 $month = (localtime $yestertime)[4] + 1;
        # day of the month
                 $day = (localtime $yestertime)[3];
        # year
                 $year = (localtime $yestertime)[5] + 1900;
        # Hours
                 $seconds = (localtime $yestertime)[0] ;
                 $minutes = (localtime $yestertime)[1] ;
                 $hours = (localtime $yestertime)[2] ;

#####Time Logic

$date =  strftime('%d-%b-%Y %H:%M',localtime); 
$arizonaTime = time - ( 86400 * (7/24)   );
$AZ_Date = strftime('%d-%b-%Y %H:%M',(localtime($arizonaTime))); 
$kuali_env_wiki = "./kuali_env.txt";
$rice_env = "$html/rice_env.cvs";
$ks_env = "$html/ks_env.cvs";
$ole_env = "$html/ole_env.cvs";
system("rm $kuali_env_wiki");
`$home/wikicat.pl > $kuali_env_wiki`;

`head -1 $kuali_env_wiki > tosstitle`;
#`grep \"rice.kuali\" $kuali_env_wiki | grep -v "ks.kuali" | grep -v "ole.kuali"  > $rice_env`;
`grep \"rice.kuali\" $kuali_env_wiki | grep -v "ks.kuali" | grep -v "ole.kuali" | grep -v "ole"  > $rice_env`;
`cat tosstitle $rice_env >> tosstemp`;
`mv tosstemp $rice_env`;
`grep \"ks.kuali\" $kuali_env_wiki > $ks_env`;
`cat tosstitle $ks_env >> tosstemp`;
`mv tosstemp $ks_env`;
`egrep \"ole.kuali|50-16-22-30\" $kuali_env_wiki > $ole_env`;
`cat tosstitle $ole_env >> tosstemp`;
`mv tosstemp $ole_env`;
`rm tosstemp tosstitle`;
