#!/usr/bin/perl 
use POSIX qw/strftime/;
$home=".";
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
$tmp = "/tmp/nightly";
$resource = "./resource";
`ssh root\@ci.rice.kuali.org mkdir $tmp`;
`scp nightly_activity.pl root\@ci.rice.kuali.org:$tmp`;
`ssh root\@ci.rice.kuali.org \"chmod 755 $tmp/nightly_activity.pl;cd $tmp;./nightly_activity.pl\"`;
`scp root\@ci.rice.kuali.org:$tmp/*.cvs $resource`;
`ssh root\@ci.rice.kuali.org \"rm $tmp/nightly_activity.pl;rm $tmp/*.cvs;rmdir $tmp\"`;

