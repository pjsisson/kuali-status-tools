#!/usr/bin/perl

#local $/ = "\r\n";

sub gettime
{
 ($in) = @_;
@parts=split(/ /, $in);
$date= $parts[1];
$time= $parts[2];
return("$date.$time");
}


$tj = "jdkdoc.txt";
`rm $tj`;
`touch $tj`;
open TJ, ">>$tj" or die "$tj : $!\n" ;

sub main 
{
 my ($cmd) = @_;
 #@x = split(/\@|\s+/,$cmd);
 #$host = $x[2];
 $file = "/tmp/file";
 #using the cat commands save the info to a file
 #`$cmd 1&>file`;
  `$cmd > $file 2>&1`;
  @env = `cat $file | grep -v Warn | grep -v \"which: no\" | grep -v "cannot access"`;
  #print "\n", $env[0];
  if ( $env[0] =~ "cannot access" ) { $cmd = "ls -l /usr/bin/java"; `$cmd > $file 2>&1`; @env = `cat $file`; }
 print "\n", $cmd;
 print "\n", @env;
  #chomp(@env);
 $row = 0;
 $col = 0;
 #   $comma = "";
 #print TJ "$comma ",$host; $comma = ","; 
 $apstrophe = "\"";
  print TJ "$comma$apstrophe"; 
 foreach $line (@env)
 {  
   #chomp($line);
    $line =~ s/\"//g;
     #print  $line; 
     print TJ $line; 
 }
  print TJ "$apstrophe"; 
  #print  "$apstrophe"; 
  #print TJ "\n";
  #print  "\n";
} ## main

#@command = ("ls -l /usr/java","which firefox","java -version", "which java");
@command = ("ls -l /usr/java;ls -l /usr/bin/java;ls -l /var/lib/jenkins/tools", "java -version", "which java");
@M = qw(env1.rice.kuali.org env2.rice.kuali.org env3.rice.kuali.org env4.rice.kuali.org env5.rice.kuali.org demo.rice.kuali.org env7.rice.kuali.org env8.rice.kuali.org env9.rice.kuali.org env10.rice.kuali.org env11.rice.kuali.org env12.rice.kuali.org env13.rice.kuali.org env1.ks.kuali.org env2.ks.kuali.org env3.ks.kuali.org env4.ks.kuali.org staging.ks.kuali.org env6.ks.kuali.org env7.ks.kuali.org env8.ks.kuali.org demo.ks.kuali.org env10.ks.kuali.org env11.ks.kuali.org env12.ks.kuali.org env13.ks.kuali.org env14.ks.kuali.org env15.ks.kuali.org dev.ole.kuali.org dev.docstore.ole.kuali.org dev.rice2.ole.kuali.org tst.ole.kuali.org tst.docstore.ole.kuali.org tst.rice2.ole.kuali.org ci.rice.kuali.org ci.fn.kuali.org ec2-204-236-253-122.compute-1.amazonaws.com);

$comma2=",";
foreach $cmd (@command)
{
  print TJ  "$comma2";
  print TJ  "$cmd";
}

  print TJ  "\n";

foreach $machine (@M)
{
 $comma = "";
  if ( $machine =~ "ec2" )
   { print TJ "$comma ","ws.rice.kuali.org"; $comma = "," }
  else
   { print TJ "$comma ",$machine; $comma = ","; }
  foreach $cmd (@command)
   {
     $enx="ssh root\@$machine  \"$cmd\"";
     #print "\n",  $enx;
     #$cmdof = $$enx;
     &main(${enx});
   }
  print TJ "\n";
}

