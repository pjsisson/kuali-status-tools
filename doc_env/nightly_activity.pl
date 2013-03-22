#!/usr/bin/perl 

 use POSIX qw(strftime);
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

$date =  strftime('%Y-%m-%d',localtime);
$endtime = time; 
#$starttime = time - ( 86400 * (24/24)   );
$starttime = time - ( 86400 * 2   );
$datepatternstart = strftime('%Y-%m-%d',(localtime($starttime )));
$datepatternend = strftime('%Y-%m-%d',(localtime($endtime )));

#print "\ndate: ",$date;
#print "\nendtime", $endtime;
#print "\nstartTime =", $starttime;
#print "\ntimeItwas24hrsago: ",$datepattern; 


  sub latestTrunk
  {
    my $url = @_[0];
    $filetmp = "/tmp/file";
    $getpom="svn cat $url/pom.xml 2>$filetmp |grep -B1 \"<version\" | head -5 |  tail -1";
    $cmdline = "getpom";
    $cmd = $$cmdline;
    $results = `$cmd`;
    chomp($results);
    if ( $results eq "" )
    { return(); };
    (@array)=split(/>|</,$results);
    $field = $array[1];
    $value = $array[2];
    return($value);

  } 

sub main
{
   $search_pattern = "/var/lib/jenkins/workspace/*/config.xml";
   @biglist = `grep spec /var/lib/jenkins/workspace/*/config.xml | egrep \"midnight|nightly|0 7 * * *\" | cut -d: -f1`;
   @biglist1 = `grep spec /var/lib/jenkins/workspace/*/config.xml | egrep \"30|daily|0 0 * * *\" | cut -d: -f1`;
   push(@biglist, @biglist1);
   print "\n", @biglist1;
   $i=0;
   $disable_pattern = "<disabled>false";
   foreach $file (@biglist)
   {
     chomp $file;
     #if ( $file =~ "ks-enr-1.0-third-party-license" )
     #{ next; }

     $output = `grep \"<disabled>false\" $file`;
     if ( $output ne "" )
     { $notdisabled[$i++] = $file; }
    }  
   foreach $file (@notdisabled)
   {
    chomp($file);
     @urls = "";
     @URL = "";
   #2012-10-18_12-32-19
    @part = split(/\//, $file);
    $dropconfigxml = pop(@part);
    $job = pop(@part);
    if ( $job eq ""){next;}
    $dir = join "/", @part;
    #$findings = `ls -c1 $dir/$job/builds | egrep \"$datepatternstart\|$datepatternend\" | wc -l`;
    $logdir = `ls -tr -c1 $dir/$job/builds | egrep \"$datepatternstart\|$datepatternend\" | tail -1`;
    chomp( $logdir);
    print "\nls -tr -c1 $dir/$job/builds | egrep \"$datepatternstart\|$datepatternend\" | tail -1";
    if ($logdir eq "" ){ next; }
    print "\n logdir: $dir/$job/builds/$logdir/log";
    $ls  = `ls -lt $dir/$job/builds/$logdir/log`;
    print "ls -lt $dir/$job/builds/$logdir/log";
    chomp($ls);
    print "\n",$ls;
    @temp = split(/\s+/,$ls);
    $logdate = $temp[5]." ".$temp[6];
    $duration_ = `grep duration $dir/$job/builds/$logdir/build.xml`;
    chomp( $duration_ );
    @duration =  split(/>|</,$duration_);
    $result_ = `grep \"<result>\" $dir/$job/builds/$logdir/build.xml`;
    print "\n", "grep \"<result>\" $dir/$job/builds/$logdir/build.xml";
    #print "\ngrep \"<url>\" $dir/$job/builds/$logdir/build.xml";
    @urls = `grep \"<url>\" $dir/$job/builds/$logdir/build.xml`;
    $i=0;
    foreach $line ( @urls )
    {
     chomp($line);
     @urls_ =  split(/>|</,$line);
     $url = $urls_[2];
     print "\nurl: ",$url;
     @output = &latestTrunk($url);
     print "\noutput: ",$output[0];
     if ( $output[0] eq "" ){next;}
     $URL[$i++]=$url;
     $URL[$i++]=$output[0];
     print POO "$url,".$output[0]."\n"; 
    }
    #print "\ngrep result $dir/$job/builds/$logdir/build.xml";
    chomp( $result_ );
    $success = "na";
    if ( $result_  ne "" )
    { 
    @result =  split(/>|</,$result_); 
    $success = $result[2];
    print "\n",$success,"\n";
    }
    $duration_time = $duration[2]/60/60/24;
    printf NT  "%-20s %-40s %-6.2f %-10s %-40s \n", "$logdate", "|$job|", "$duration_time", "|$success","|@URL";
 }
}

$home = ".";
$nightly_jenkins_txt = "$home/nightly_jenkins.txt";
$nightly_jenkins_data = "$home/nightly_jenkins_data.txt";
$nightly_jenkins_header = "$home/nightly_jenkins_header.txt";
$nightly_jenkins_sortedtxt = "$home/nightly_jenkins_sorted.txt";

open NT, ">>$nightly_jenkins_sortedtxt" or die "$nightly_jenkins_sortedtxt : $!\n" ;
$POO = "PoO";
$PoO = "PoO";
`rm $POO;touch $POO`;
$RICEPOO =  $PoO."rice.cvs";
$STUDENTPOO = $PoO."student.cvs";
$OLEPOO = $PoO."ole.cvs";
$wiki="/usr/local/tomcat/";
open POO, ">>$POO" or die "$POO : $!\n" ;
&main();
close NT;
close POO;
#create a rice file
`sort $POO | uniq | grep rice  > $RICEPOO`;
`sort $POO | uniq | grep student  > $STUDENTPOO`;
`sort $POO | uniq | grep ole  > $OLEPOO`;
#`cp $RICEPOO $STUDENTPOO $OLEPOO $wiki`; 
#print "\nsort $nightly_jenkins_sortedtxt > $nightly_jenkins_data";
`sort $nightly_jenkins_sortedtxt > $nightly_jenkins_data`;
open HEADER, ">$nightly_jenkins_header" or die "$nightly_jenkins_header : $!\n" ;
printf HEADER  "%-20s %-40s %-6s %-10s %-40s \n", "log date", "|job", "|duration minutes", "|success","|URL- Label";
`cat $nightly_jenkins_header $nightly_jenkins_data > $nightly_jenkins_txt`;
print "$nightly_jenkins_txt";
system("rm $POO $nightly_jenkins_txt $nightly_jenkins_data $nightly_jenkins_header $nightly_jenkins_sortedtxt");
