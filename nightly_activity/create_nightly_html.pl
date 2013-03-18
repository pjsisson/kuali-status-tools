#!/usr/bin/perl 
use POSIX qw/strftime/;
$home="/home/ubuntu/scripts/nightly_activity";
$html="/usr/local/tomcat/";
#$html=".";

$nightly_jenkins_txt = "$home/nightly_jenkins.txt";
#`$home/nightly_activity.pl > $nightly_jenkins_txt`;
`$home/nightly_activity.pl`;

print "\n$nightly_jenkins_txt";
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
$nightly_jenkins_html = "$html/nightly_jenkins.html";
system("rm $nightly_jenkins_html");
open KE, ">>$nightly_jenkins_html" or die "$nightly_jenkins_html : $!\n" ;

print "\n$nightly_jenkins_txt";
open ( KT,  "<$nightly_jenkins_txt"); (@valuein =<KT>); close (KT);
$row=-1;
@value=();
foreach $line ( @valuein )
{
   @COL = split("\\|", $line);
   $size = @COL;
   print "\nsize: $size";
   $row++;
   $column=0;
   foreach $item (@COL)
   {
      print "\n",$item;
      if ( $column == 1 ){ $item = "<a href=\"http:\/\/ci.rice.kuali.org/job/$item\">$item<\/a>" };
      $value[$row][$column] =  $item;
      $column++;
   }
 } 

$number_rows=$row;
$number_columns=$column-1;
$last_column = $number_columns;
$header = "yes";

printf KE "<!DOCTYPE HTML PUBLIC \"-\/\/W3C\/\/DTD HTML 4.0 Transitional\/\/EN\">\n";

printf KE "<HTML>\n";
printf KE "<HEAD>\n";
printf KE "<META HTTP-EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=utf-8\">\n";
printf KE "<TITLE>Environment Information captured: $date</TITLE>";
printf KE "<\/HEAD>\n";
printf KE "<BODY LANG=\"en-US\" DIR=\"LTR\">\n";
printf KE "Environment Information captured: $date GMT - Arizona Time $AZ_Date ";
printf KE "<table border=\"1\">\n";
$grey_start ="<p style=\"background-color:\#C0C0C0\">";
$grey_end ="<\/p>";

for ( $row=0; $row <= $number_rows; $row++ )
{
   if (($row == 0)){ $header = "yes"; $env_no=1;  }else{ $header = "no"};
   if ( $header eq "yes" ){ $row_tag_start = "<th>"."$grey_start"; $row_tag_end = "$grey_end"."<\/th>";  }
   else
    { $row_tag_start = "<td>"; $row_tag_end = "<\/td>";  }

    if ( $row != 0 ) 
    {
      printf KE "$row_tag_start$env_no$row_tag_end"; 
      $env_no++;}
    else
    {  printf KE "$row_tag_start"."#"."$row_tag_end"; }
    
   for ( $column=0; $column <= $number_columns; $column++ )
   {
        if (( $column == $last_column ) && ($row >= 1))
        {
         @last_col_values=  split (/\s+/, $value[$row][$column] );
         $number_elements = @last_col_values;
         $number_elements--;
         $number_inner_rows = $number_elements/2;
         $number_inner_cols = 2;
         $index=0;
         printf KE "<td>";
         printf KE "<table>";
         for( $inner_row=0; $inner_row <= $number_inner_rows; $inner_row++ )
           {
            printf KE "<tr>";
            printf KE "$row_tag_start$last_col_values[$index++]$row_tag_end";
            printf KE "$row_tag_start$last_col_values[$index++]$row_tag_end";
            printf KE "<\/tr>";
           }
         printf KE "<\/table>";
         printf KE "<\/td>\n";
        }
        else
        {
        printf KE "$row_tag_start$value[$row][$column]$row_tag_end";
       }
    }
   printf KE "<\/tr>\n";
}
print KE "<\/table>\n";
print KE "<\/BODY>\n";
print KE "<\/HTML>\n";

close KE;
