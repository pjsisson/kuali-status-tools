#!/usr/bin/perl 

#This is a very simple script which takes a java generated cvs file ( aws-s3-summary.csv )
#and formats it so Concluences Wiki Charting plugin will work with it.
#The data is reprinted at  rice.ci /usr/local/tomcat and read by rice wiki section
#11/28/2012

use LWP::Simple;
use POSIX qw/strftime/;
$home="/home/ubuntu/scripts/latest_shrub";
$html="/usr/local/tomcat/";
system("rm $html/MavenTotalTrend.cvs");
system("touch $html/MavenTotalTrend.cvs");
open ( M,  ">>$html/MavenTotalTrend.cvs");
print M "Day,maven\n";
$svns3 = "http://svn.kuali.org/repos/foundation/trunk/kuali-ci/src/main/resources/aws-s3-summary.csv";
@s3sum = split(/\n/, get "$svns3");
#copy over the cvs files 
foreach  $element ( @s3sum )
 {  @parts = split(/,/, $element); 
     #site.origin.kuali.org,4260206,105391600436,2012-11-16T05:47:38.902+0000
     ($date,$timex) = split(/T/, $parts[3]);
     $date =~ s/-/\//g;
     ($yy,$mm,$dd) = split(/\//, $date);
     $date = $yy ."/".$dd."/".$mm;
     $bucket = $parts[0];
     $nofiles = $parts[1];
     $byte = $parts[2];
    if ( $bucket =~ "maven" ){
     print M "$date,$byte\n";
     }
   }
close M;
system("rm $html/SiteTotalTrend.cvs");
system("touch $html/SiteTotalTrend.cvs");
open ( S,  ">>$html/SiteTotalTrend.cvs");
print S "\n\nDay,site\n";
 $svns3 = "http://svn.kuali.org/repos/foundation/trunk/kuali-ci/src/main/resources/aws-s3-summary.csv";
 @s3sum = split(/\n/, get "$svns3");
  foreach  $element ( @s3sum )
  {  @parts = split(/,/, $element);
     #site.origin.kuali.org,4260206,105391600436,2012-11-16T05:47:38.902+0000
     ($date,$timex) = split(/T/, $parts[3]);
     $date =~ s/-/\//g;
     ($yy,$mm,$dd) = split(/\//, $date);
     $date = $yy ."/".$dd."/".$mm;
     $bucket = $parts[0];
     $nofiles = $parts[1];
     $byte = $parts[2];
    if ( $bucket =~ "site" ){
     print S "$date,$byte\n";
     }
   }
close S;
