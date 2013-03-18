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
$jdk_env = "$html/jdk_env.cvs";
#`$home/env_jdk_query.pl > $jdk_env`;
`$home/jdkquery.pl`;
`cp /$home/jdkdoc.txt  $html/jdk_envx.cvs; `;

