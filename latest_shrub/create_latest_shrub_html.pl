#!/usr/bin/perl 

use LWP::Simple;
#local $/ = "\r\n";
use POSIX qw/strftime/;
$home="/home/ubuntu/scripts/latest_shrub";
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

#set up the dates for HTML
$date =  strftime('%d-%b-%Y %H:%M',localtime); 
$arizonaTime = time - ( 86400 * (7/24)   );
$AZ_Date = strftime('%d-%b-%Y %H:%M',(localtime($arizonaTime))); 

$row=-1;
@value=();
@valuein=();

$number_rows=$row;
$number_columns=$column-1;
$last_column = $number_columns;
$header = "yes";


################################
sub LatestVersion
################################
{

  my @metadata = @_;

 $i=0;
 @tmp = ();
 foreach $item (@metadata)
 {   $tmp[$i++] = $item."\n"; $x = $i; }

 open ( M,  ">/tmp/metadata.txt");
 #write the metadata to a local file for manupulation.
 print M @tmp;
 close M;
 #find the line with lastUpdated and save
 @UL=  split(/>|</,`grep lastUpdated /tmp/metadata.txt`);
 $size = @UL;

 #find line with version ending with a >
 @REL=  split(/>|</,`grep \"version>\" /tmp/metadata.txt | tail -1`);
 $lastUpdated = $UL[2];
 $latestRelease = $REL[2];
 #clean up
 system("rm /tmp/metadata.txt");

return($latestRelease);
}

######################
sub yankVersion
######################
{
my @pom = @_;

foreach $line (@pom)
{
   chomp($line);
   (@components) = split(/<|>/, $line);
   if ( $components[1] eq "version")
   {
      return($components[2]);
   }
 }
} #yankVersion


sub getPomInfo
{
  $svnkp = "http://svn.kuali.org/repos/foundation/trunk/kuali-pom/pom.xml";
  @pompom = split(/\n/, get "$svnkp");
  @kpContent =  yankVersion(@pompom);

  $svnkc = "http://svn.kuali.org/repos/foundation/trunk/kuali-pom/kuali-common/pom.xml";
  @commonpom = split(/\n/, get "$svnkc");
  @kcContent =  yankVersion(@commonpom);

  $svnkm = "http://svn.kuali.org/repos/foundation/trunk/kuali-pom/kuali-common/kuali-maven/pom.xml";
  @mavenpom =  split(/\n/, get "$svnkm");
  @kmContent =  yankVersion(@mavenpom);

  printTable("svn");

  $shrubkp_rel = "http://maven.kuali.org.s3.amazonaws.com/release/org/kuali/pom/kuali-pom/maven-metadata.xml";
  @metadata = split(/\n/, get "$shrubkp_rel");
  @kpContent = LatestVersion(@metadata);

  $shrubkc_rel = "http://maven.kuali.org.s3.amazonaws.com/release/org/kuali/pom/kuali-common/maven-metadata.xml";
  @metadata = split(/\n/, get "$shrubkp_rel");
  @kcContent = LatestVersion(@metadata);

  $shrubkm_rel = "http://maven.kuali.org.s3.amazonaws.com/release/org/kuali/pom/kuali-maven/maven-metadata.xml";
  @metadata = split(/\n/, get "$shrubkm_rel");
  @kmContent = LatestVersion(@metadata);

  printTable("shrub Release");

  $shrubkp_snap = "http://maven.kuali.org.s3.amazonaws.com/snapshot/org/kuali/pom/kuali-pom/maven-metadata.xml";
  @metadata = split(/\n/, get "$shrubkp_snap");
  @kpContent = LatestVersion(@metadata);

  $shrubkc_snap = "http://maven.kuali.org.s3.amazonaws.com/snapshot/org/kuali/pom/kuali-common/maven-metadata.xml";
  @metadata = split(/\n/, get "$shrubkc_snap");
  @kcContent = LatestVersion(@metadata);

  $shrubkm_snap = "http://maven.kuali.org.s3.amazonaws.com/snapshot/org/kuali/pom/kuali-maven/maven-metadata.xml";
  @metadata = split(/\n/, get "$shrubkm_snap");
  @kMContent = LatestVersion(@metadata);

  printTable("shrub Snapshot");

#$svnkp = "http://nexus.kuali.org/service/local/repositories/kuali-release/content/org/kuali/pom/kuali-maven";
  #@pompom = split(/\n/, get "$svnkp");
  # write routine to search  lastModified date http://nexus.kuali.org/service/local/repositories/kuali-release/content/org/kuali/pom/kuali-maven/?
}

##################################
#print the Pom Info Tables
##################################
sub printTable
##################################
    {
       $area = @_[0];
       print LRH "<br>";
       print LRH "<table border=\"1\">\n";
       print LRH "$row_start";
       print LRH "$col_start";
       print LRH "$area kuali-pom";
       print LRH "$col_end";
       print LRH "$col_start";
       print LRH "$area kuali-common";
       print LRH "$col_end";
       print LRH "$col_start";
       print LRH "$area kuali-maven";
       print LRH "$col_end";
       print LRH "$row_end";

       print LRH "$row_start";
       print LRH "$col_start";
       print LRH  @kpContent;
       print LRH "$col_end";
       print LRH "$col_start";
       print LRH  @kcContent;
       print LRH "$col_end";
       print LRH "$col_start";
       print LRH  @kmContent;
       print LRH "$col_end";
       print LRH "$row_end";
       print LRH "<\/table>\n";
       print LRH "<br>";
}
   


#This helps identify versions by first segment x.x.x-AAA-BBB
#builds index of x.x.x for finding older versions
#############################
sub get_unique_index
#############################
{
system("rm /tmp/tmplatest.txt");
system("rm /tmp/tmplatestuniq.txt");
open ( P,  ">>/tmp/tmplatest.txt");

foreach $line (@metadata)
{

   ( @V ) = split(/>|</, $line );

   $version = $V[2];
   $metadata = $V[1];
   @parts = split(/\-/, $version);
   if ( $metadata eq "version" )
   {
      print P  $parts[0],"\n";
   }
}

`sort /tmp/tmplatest.txt | uniq > /tmp/tmplatestuniq.txt`;
@version_unique_index = `tail -10 /tmp/tmplatestuniq.txt`;
return( @version_unique_index);
}

#Find archived versions in the maven-metadata.xml file
################################
sub TreeLatestUnique
################################
{

$project = @_[0];
$branch = @_[1];
$app = @_[2];
@metadata=();
#print "\nget \"http://maven.kuali.org.s3.amazonaws.com/$branch/org/kuali/$project/$app/maven-metadata.xml\"";
@metadata = split(/\n/, get "http://maven.kuali.org.s3.amazonaws.com/$branch/org/kuali/$project/$app/maven-metadata.xml");
@index=&get_unique_index();
#print "\n$project $branch $app";
#print "\nindex: ",@index;
return(@index);
}

#find the latest version in the maven-metadata.xml file
################################
sub TreeLatest
################################
{
 $project = @_[0];
 $branch = @_[1];
 $app = @_[2];
 #print "\nget \"http://maven.kuali.org.s3.amazonaws.com/$branch/org/kuali/$project/$app/maven-metadata.xml\"";
 @metadata = split(/\n/, get "http://maven.kuali.org.s3.amazonaws.com/$branch/org/kuali/$project/$app/maven-metadata.xml");

 $i=0;
 @tmp = ();
 foreach $item (@metadata)
 {   $tmp[$i++] = $item."\n"; $x = $i; }

 open ( M,  ">/tmp/metadata.txt");
 #write the metadata to a local file for manupulation. 
 print M @tmp;
 close M;
 #find the line with lastUpdated and save
 @UL=  split(/>|</,`grep lastUpdated /tmp/metadata.txt`);
 $size = @UL;

 #find line with version ending with a >
 @REL=  split(/>|</,`grep \"version>\" /tmp/metadata.txt | tail -1`);
 $lastUpdated = $UL[2];
 $latestRelease = $REL[2];
 #clean up
 system("rm /tmp/metadata.txt");

return($lastUpdated, $latestRelease);
}

####################################################
sub print_release_page
####################################################
{

 my $project = @_[0];
 #html file
  $latest_revisions_html = "$html/latest_".$project."_revisions.html";
  system("rm $latest_revisions_html");
  open LRH, ">>$latest_revisions_html" or die "$latest_revisions_html : $!\n" ;

printf LRH "<!DOCTYPE HTML PUBLIC \"-\/\/W3C\/\/DTD HTML 4.0 Transitional\/\/EN\">\n";

printf LRH "<HTML>\n";
printf LRH "<HEAD>\n";
printf LRH "<META HTTP-EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=utf-8\">\n";
printf LRH "<TITLE>List Latest Projects Versions in Shrub: $date</TITLE>";
printf LRH "<\/HEAD>\n";
printf LRH "<BODY LANG=\"en-US\" DIR=\"LTR\">\n";
printf LRH "Information captured: $date GMT - Arizona Time $AZ_Date ";
printf LRH "<table border=\"1\">\n";
$grey_start ="<p style=\"background-color:\#C0C0C0\">";
$grey_end ="<\/p>";
$number_columns = 3;
$col_start = "<td>";
$col_end = "<\/td>";
$col_header_start  = "<th>";
$col_header_stop  = "<\/th>";
$row_start = "<tr>";
$row_end = "<\/tr>";
$span3 = "COLSPAN=21";
$span2 = "COLSPAN=2";
$center = "align=\"center\"";
$col_start_one = "<TD $colspan_project $center>";
$col_branch_title = "<TD $colspan_branch $center>";
$col_app_title = "<TD $colspan_apps $center>";

  printf LRH "$row_start";
  printf LRH "$col_start_one";
  printf LRH "$grey_start";
  printf LRH "<B>$project<\/B>";
  printf LRH "$grey_stop";
  printf LRH "$col_end";
  printf LRH "$row_end\n";

    # This prints each branch  under the project name
    $col_branch_title = "<TD $colspan_branch $center>";
    print LRH "\n$row_start";
    foreach  $branch_title (@branches)
    {
      print LRH "$col_branch_title$grey_start<B>$branch_title<\/B>$grey_stop$col_end";
    }
      print LRH "$row_end";

    #This is going to print each application under each branch
    print LRH "\n$row_start";
    foreach  $branch (@branches)
    {
    print LRH "$col_app_title";
    print KD "$start_grey";

    foreach  $app_title (@apps)
    {
      $shrub= "<a href=\"http:\/\/shrub.appspot.com/maven.kuali.org/$branch/org/kuali/$project/$app_title/\">$app_title<\/a>";
      #print LRH "$app_title <br> ";
      print LRH "$shrub <br> ";
    }
    print LRH "$col_end";
   }
    print LRH "$row_end\n";
    print LRH "$row_start";
    #print the fields names title
    foreach  $branch (@branches)
    {
     foreach $app (@apps)
     {
      foreach $field ( @fields)
      {
        print LRH "$col_start$field$col_end";
      }
      last; 
    }
    }
      print LRH "$row_end";
      print LRH "$row_start"; 
  foreach  $branch (@branches)
    {
    foreach $app (@apps)
    {
        (@wood) = &TreeLatest( $project , $branch, $app );
        $lastUpdated_unformatted = $wood[0];
        $year = substr($lastUpdated_unformatted, 0, 4);
        $month = substr($lastUpdated_unformatted, 4, 2);
        $day = substr($lastUpdated_unformatted, 6, 2);
        $hour = substr($lastUpdated_unformatted, 8, 2); 
        $minx = substr($lastUpdated_unformatted, 10, 2 ) ;
        $lastUpdated_formatted = "$month-$day-$year $hour:$minx";
        $latestRelease_field = $wood[1];

        $shrub= "<a href=\"http:\/\/shrub.appspot.com/maven.kuali.org/$branch/org/kuali/$project/$app/$latestRelease_field/\">$latestRelease_field<\/a>";
        print LRH "$col_start$shrub$col_end$col_start$lastUpdated_formatted$col_end";
        last;
     }
    }
      print LRH "$row_end";

print LRH "<\/table>\n";
print LRH "<br><br>";

#Start the second table
printf LRH "<p><B> <FONT SIZE=+2>".uc( $project)." - archived versions<\/B><\/p>"; 
$col_app_title_a = "<TD $colspan_apps_a $center>";
printf LRH "<table border=\"1\">\n";
print LRH "$row_start";
foreach  $branch (@branches)
 {
   print LRH "$col_app_title_a";
   print LRH "$grey_start$branch$grey_stop";
    print LRH "$col_end";
   }
  print LRH "$row_end";

 foreach  $branch (@branches)
 {
    foreach $app (@apps)
    {
      open ( M,  "</tmp/metadata.txt"); (@metadata =<M>); close (M);
      #print "\nmetadata", @metadata;
      (@index) = &TreeLatestUnique( $project , $branch, $app );
      #print "\n->index: ",@index;
      #print LRH "$col_app_title";
      print LRH "$col_start";
      print LRH "$app <br>";
      foreach $version_unique (@index)
      {
        #print "\nversion_unique: $version_unique";
        $shrub= "<a href=\"http:\/\/shrub.appspot.com/maven.kuali.org/$branch/org/kuali/$project/$app/$version_unique"."\?"."/\">$version_unique<\/a>";
        print LRH "$shrub <br>";
      }
       print LRH "$col_end";
   }
 }
print LRH "$row_end";
print LRH "<\/table>\n";
&getPomInfo();

print LRH "<\/BODY>\n";
print LRH "<\/HTML>\n";

close LRH;
}

#############################
sub main
#############################
{

@projects = ( "rice","student","ole");
@branches = ( "builds","snapshot","release");
@fields = ("release","lastUpdated");
@rice = ( "rice-web", "rice-sampleapp");
@student = ( "web\/ks-with-rice-embedded","web\/ks-with-rice-bundled","web\/ks-rice-standalone","web\/ks-embedded");
@ole = ( "ole");

foreach $project (@projects)
{
    @apps = ();
    #capture the applications for each project, as it's called
    if ( $project eq "rice" ){ push ( @apps, @rice);}
    if ( $project eq "student" ){ push ( @apps, @student); }
    if ( $project eq "ole" ){ push ( @apps, @ole); }

    #span size is for html formatting
    $app_size_span = @apps;
    $app_size_span_a = $app_size_span; 
    $app_size_span = 1;
    $branch_size_span = @branches;
    $branch_size_span + 1;
    $field_size_span = @fields;
    $field_size_span + 1;
    $project_span = $app_size_span * $branch_size_span * $field_size_span;
    $branch_span = $app_size_span *  $field_size_span;
    $app_span = $field_size_span;
    $colspan_project = "COLSPAN=$project_span"; 
    $colspan_branch = "COLSPAN=$branch_span"; 
    $colspan_apps = "COLSPAN=$app_span"; 
    $colspan_apps_a = "COLSPAN=$app_size_span_a"; 
    ####################################################
    &print_release_page($project);
    ####################################################
 }
}

&main();
