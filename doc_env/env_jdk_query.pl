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



sub main 
{
 my ($cmd) = @_;
 $file = "/tmp/file";
 #using the cat commands save the info to a file
 #`$cmd 1&>file`;
  `$cmd > $file 2>&1`;
  @env = `cat $file`;
  chomp(@env);
 $row = 0;
 $col = 0;
    $comma = "";
 foreach $line (@env)
 {  @a = split(/\s/,$line);
    foreach $x (@a)
    {  
        $x =~ s/\"|\'|\)//g;
        if ( $x =~ "ec2" ){ $x = "workspace-server"; }
       if ((( $row == 0 ) && ($col == 3)) ||  (( $row == 2 ) && ($col == 5)) ||  (( $row == 1 ) && ($col == 2)))
       {    if ( ( $row == 0 ) && ($col == 3)) { @y = split(/,/, $x); $x = $y[0]; } 
                print "$comma ",$x; $comma = ","; }
       $col++;
    }
   $row++;
   $col = 0;
}

   print "\n";
} ## main

foreach $cmd (@command)
{
$env1_rice="ssh root\@env1.rice.kuali.org  java -version";
$env2_rice="ssh root\@env2.rice.kuali.org  java -version";
$env3_rice="ssh root\@env3.rice.kuali.org  java -version";
$env4_rice="ssh root\@env4.rice.kuali.org  java -version";
$env5_rice="ssh root\@env5.rice.kuali.org  java -version";
$demo_rice="ssh root\@demo.rice.kuali.org  java -version";
$env7_rice="ssh root\@env7.rice.kuali.org  java -version";
$env8_rice="ssh root\@env8.rice.kuali.org  java -version";
$env9_rice="ssh root\@env9.rice.kuali.org  java -version";
$env10_rice="ssh root\@env10.rice.kuali.org  java -version";
$env11_rice="ssh root\@env11.rice.kuali.org  java -version";
$env12_rice="ssh root\@env12.rice.kuali.org  java -version";
$env13_rice="ssh root\@env13.rice.kuali.org  java -version";


$env1_ks="ssh root\@env1.ks.kuali.org  java -version";
$env2_ks="ssh root\@env2.ks.kuali.org  java -version";
$env3_ks="ssh root\@env3.ks.kuali.org  java -version";
$env4_ks="ssh root\@env4.ks.kuali.org  java -version";
$staging_ks="ssh root\@staging.ks.kuali.org  java -version";
$env6_ks="ssh root\@env6.ks.kuali.org  java -version";
$env7_ks="ssh root\@env7.ks.kuali.org  java -version";
$env8_ks="ssh root\@env8.ks.kuali.org  java -version";
$demo_ks="ssh root\@demo.ks.kuali.org  java -version";
$env10_ks="ssh root\@env10.ks.kuali.org  java -version";
$env11_ks="ssh root\@env11.ks.kuali.org  java -version";
$env12_ks="ssh root\@env12.ks.kuali.org  java -version";
$env13_ks="ssh root\@env13.ks.kuali.org  java -version";


$env1_ole="ssh root\@dev.ole.kuali.org  java -version";
$env2_ole="ssh root\@dev.docstore.ole.kuali.org java -version";
$env3_ole="ssh root\@dev.rice2.ole.kuali.org  java -version";
$env4_ole="ssh root\@tst.ole.kuali.org  java -version";
$env5_ole="ssh root\@tst.docstore.ole.kuali.org  java -version";
$env6_ole="ssh root\@tst.rice2.ole.kuali.org  java -version";
$env7_ole="ssh root\@env7.ole.kuali.org  java -version";
$env8_ole="ssh root\@env8.ole.kuali.org  java -version";
$env9_ole="ssh root\@env9.ole.kuali.org  java -version";


$ci="ssh root\@ci.rice.kuali.org  java -version";
$workspace="ssh root\@ec2-204-236-253-122.compute-1.amazonaws.com  java -version";
$r= 0;

$fn="ssh root\@ci.fn.kuali.org  java -version";

@rice = ( "env1_rice", "env2_rice", "env3_rice","env4_rice","env5_rice", "demo_rice","env7_rice","env8_rice", "env9_rice", "env10_rice","env11_rice","env12_rice","env13_rice");
$ssize_=@rice;
for ( $index = 0; $index < $ssize_; $index++ ) 
{
  $project = "rice";
  $project1 = "rice";
  $env_no = $index + 1 ;
  $env=$rice[$index];
  $env1 = $env .$delimitor;
  $cmd = $$env;
  $env1 = $t[0]. $delimitor;
  &main(${cmd});
}

@student = ( "env1_ks", "env2_ks", "env3_ks","env4_ks", "staging_ks","env6_ks", "env7_ks", "env8_ks","demo_ks","env10_ks","env11_ks","env12_ks","env13_ks");
$ssize_=@student;
for ( $index = 0; $index < $ssize_; $index++ )
{
  $project = "ks";
  $project1 = "student";
  $env_no = $index + 1 ;
  $env=$student[$index];
  $env1 = $env .$delimitor;
  $cmd = $$env;
  $env1 = $t[0].$delimitor;
  &main(${cmd});
}


@ole = ( "env1_ole", "env2_ole", "env3_ole","env4_ole","env5_ole","env6_ole","env7_ole","env8_ole","env9_ole");
$ssize_=@ole;
for ( $index = 0; $index < $ssize_; $index++ )
{
  $project = "ole";
  $project1 = "ole";
  $env_no = $index + 1 ;
  $env=$ole[$index];
  $env1 = $env ."$delimitor";
  $cmd = $$env;
  $env1 = $t[0]. "$delimitor";
  &main(${cmd});
}

@server = ( "ci", "workspace","fn");
$ssize_=@server;
for ( $index = 0; $index < $ssize_; $index++ )
{
  $project = "server";
  $project1 = "server";
  $env_no = $index + 1 ;
  $env=$server[$index];
  $env1 = $env ."$delimitor";
  $cmd = $$env;
  $env1 = $t[0]. "$delimitor";
  &main(${cmd});
}
