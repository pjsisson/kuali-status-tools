#!/usr/bin/perl

use LWP::Simple;
local $/ = "\r\n";
$delimitor = ",";

# Convert the env hyperlink to href-html type links
sub changeEnvLink
{
  my @varIn = @_;
  my $pathx = 4;
  my $serverx = 2;
  my @temp = split(/\@|\s+/, $varIn[0]);
  #return( "<a href=\"http:\/\/$temp[$serverx]\">$temp[$serverx]<\/a>");
  my $returnvalue = "[".$temp[$serverx]."|http:\/\/".$temp[$serverx]."]";
  return( $returnvalue);
}

sub gettime
{
 ($in) = @_;
@parts=split(/ /, $in);
$date= $parts[1];
$time= $parts[2];
return("$date.$time");
}

sub up
{
  my $path = @_[0];
  $http = 1;
  $skip = 2;
  $svn = 3;
  $repos = 4;
  $trunk = "trunk";
  my $project =  5;
  my $path = @_[0];
  @p = split(/\//, $path);
  $atprojectlevel = @p;
  #print "\nlevel: ", $atprojectlevel;
  if ( $atprojectlevel == $project )
  { $reconstruct = join "/", @p;
    @reconstruct_path[0] = $reconstruct . "/". "$trunk"; }
  else {
   $toss = pop(@p);
   $reconstruct = join "/", @p;
   #print "\n", $reconstruct, "toss: ",$toss;;
   $reconstruct_path[0] = $reconstruct; }
   #print "\narray: ",  @reconstruct_path ;
return( @reconstruct_path );
}


sub latest_kuali_common_version
{
  my @pathin = @_;
  my $value_index = 2;
  #$kuali_common = "http://svn.kuali.org/repos/foundation/trunk/kuali\-pom/kuali\-common/pom.xml";
  $kuali_common = "http://maven.kuali.org.s3.amazonaws.com/release/org/kuali/pom/kuali-pom/maven-metadata.xml";
  @commonpomfile = split(/\n/, get "$kuali_common");
  @rev_commonpomfile = reverse(@commonpomfile);
  @commonpomfile = @rev_commonpomfile;
  #print "\n", $kuali_common;
  #print "\n", @commonpomfile;
  $found = 0;
  foreach $pomline ( @commonpomfile ){
  chomp($pomline);
  if ( $pomline =~ "version>" ) {
     @V = split(/>|</, $pomline);
     $latest_pom_version = $V[$value_index];
     $lpv = "<a href=\"http:\/\/maven.kuali.org.s3.amazonaws.com/release/org/kuali/pom/kuali\-pom/$latest_pom_version/kuali\-pom\-$latest_pom_version.pom\">$latest_pom_version<\/a>";
     $lpv = "[$latest_pom_version|http:\/\/maven.kuali.org.s3.amazonaws.com/release/org/kuali/pom/kuali\-pom/$latest_pom_version/kuali\-pom\-$latest_pom_version.pom]";
      #http://maven.kuali.org.s3.amazonaws.com/release/org/kuali/pom/kuali-pom/2.0.10/kuali-pom-2.0.10.pom
      #http://shrub.appspot.com/maven.kuali.org/release/org/kuali/pom/kuali-pom/2.0.10/
     #print "\nlatest_pom_version: ", $latest_pom_version;
     last; }
  }
  do {
   $found = 0;
   @shorter_path = up(@pathin);
   @pathin = @shorter_path;
   my $newpath = $shorter_path[0];
   $pom = $newpath . "/". "pom.xml";
   #print "\npom: ",$pom;
   @pomfile = split(/\n/, get "$pom");
   foreach $line ( @pomfile) {
    chomp($line);
    if ( $line =~ "kuali-common" ) { $found = 1;  next; }
    if ( $found == 1 ) {  
     @V = split(/>|</, $line);
     $version = $V[$value_index];
     $pLpv = "<a href=\"$newpath/pom.xml\">$version<\/a>";
     $pLpv = "[$version|$newpath/pom.xml]";
     last; }
   } #foreach
    } #do
    until ( $version ne "" ) ;
  $kuali_common_version[0] = $pLpv;
  $kuali_common_version[1] = $lpv;
  return( @kuali_common_version );
} # latest_kuali_common_version

sub main 
{
 my ($cmd) = @_;
 $file = "/tmp/file";
  $date="---$delimitor";
  $bundle_version="---$delimitor";
  $svn_rev="---$delimitor";
  $jdk="---$delimitor";
  $jobs="---$delimitor";
  $svn_tag="---$delimitor";
  $kuali_common="---$delimitor";
  $kuali_common_latest="---$delimitor";
  $shrub="---$delimitor";
 #using the cat commands save the info to a file
 @env = ();
 @Renv = ();
 @env = `$cmd 2>$file`;
 system("rm $file");
 chomp(@env);
 @FIELD=();
 @VALUE=();
 @Renv = reverse(@env);
 @env= ();
 @Henv= ();
 #the META-INF/MANIFEST.MF file has hard breaks in lines. This reconnects them.
 foreach $line (@Renv)
 {
   chomp($line);
   @space=split(//, $line);
   if ( $space[0] eq " " )
   {  $line =~ s/^\s+//; $hold = $line;  }
   else
   {  $line = $line.$hold; push (@Henv,$line); $hold= ""; }
  }

 @env = reverse(@Henv);
 #This queries the META-INF/MANIFEST.MF for information
 foreach $line (@env)
 {
  chomp($line);
  ($field,$value)=split(/:/,$line, 2);
   push(@FIELD,$field);
   push(@VALUE,$value);
   chomp($VALUE[$i]);
   #print "$field: VALUE $i", $VALUE[$i],".\n";
   if ( $field =~ "Time" )
   { $date = &gettime($value) .$delimitor;}
   if ( $field =~ "Bundle-Version")
   {  $value =~ s/\s+//g;
      $bundleId = $value;
      $bundle_version= "[$value|http:\/\/nexus.kuali.org/index.html\#nexus-search\;gav\~\~\~$value\*\~\~\]".$delimitor; 
   }
      $shrub_branch = "release"; #default
      #print "\nsvn_tag: $svn_tag";
      #print "\nbundleId: $bundleId";
      if ( $svn_tag =~ "SNAPSHOT" || $bundleId =~ "SNAPSHOT"){$shrub_branch = "snapshot" };
      if ( $svn_tag =~ "build"  || $bundleId =~ "build" ){$shrub_branch = "builds" };
      if ( $project1 eq "rice" ){
        #$shrub= "<a href=\"http:\/\/shrub.appspot.com/maven.kuali.org/$shrub_branch/org/kuali/$project1/$project1\-$lastapp/$bundleId/\">$bundleId<\/a>";
        $shrub= "[$bundleId|http:\/\/shrub.appspot.com/maven.kuali.org/$shrub_branch/org/kuali/$project1/$project1\-$lastapp/$bundleId]";
        }
        
      if ( $project1  eq "student"){
        $shrub="<a href =\"http:\/\/shrub.appspot.com/maven.kuali.org/$shrub_branch/org/kuali/$project1/web/$lastapp/$bundleId/\">$bundleId<\/a>"; 
        $shrub= "[$bundleId|http:\/\/shrub.appspot.com/maven.kuali.org/$shrub_branch/org/kuali/$project1/web/$lastapp/$bundleId]";
      }

      if ( $project1  eq "ole"){
        $shrub="<a href =\"http:\/\/shrub.appspot.com/maven.kuali.org/$shrub_branch/org/kuali/$project1/$lastapp/$bundleId/\">$bundleId<\/a>";
        $shrub="[$bundleId|http:\/\/shrub.appspot.com/maven.kuali.org/$shrub_branch/org/kuali/$project1/$lastapp/$bundleId]";
      }
     push(@FIELD,"shrub");
     push(@VALUE,$shrub);
     $i++;
   if ( $field =~ "SVN-Revision" )
   { $svn_rev = $value.$delimitor; }
   if ( $field =~ "Build-Jdk" )
   {  $jdk = $value.$delimitor; }
   if ( $field =~ "SVN-Path" )
   {  @SVN_PATH= split(/\//,$value);
      $value =~ s/\s+//g;
      $svn_tag="<a href=\"http:\/\/svn.kuali.org/repos/$project1/$value\">$value<\/a>$delimitor";
      $svn_tag="[$value|http:\/\/svn.kuali.org/repos/$project1/$value].$delimitor";
      chomp($VALUE[$i]);
      @pullapart = split(/\//,$value);
      $size = @pullapart;
      $pindex = $size -1;
      $lastapp = $pullapart[$pindex];
      $secondlastapp = $pullapart[$pindex-1];
      #<artifactId>kuali-common</artifactId>
      #<version>1.7.1</version>
      @kuali_common_array = latest_kuali_common_version("http:\/\/svn.kuali.org/repos/$project1/$value");
      $kuali_common = $kuali_common_array[0].$delimitor;
      $kuali_common_latest  = $kuali_common_array[1].$delimitor;
      }
   #print "$i ", "$field ", ">$value\n";
  $i++;
 }
  $jobcmd = "ssh ubuntu\@ci.rice.kuali.org /home/ubuntu/scripts/doc_env/serverside_searchenvcvs.pl $env_no $project"; 
  $jobs = `$jobcmd 2>file`;
  $jobs = $jobs.$delimitor;
  printf "%-3s%-12s%-20s%-30s%-20s%-20s%-30s%-20s%-20s%-20s%-20s\n",$env_no.$delimitor,$env1,$date,$bundle_version,$svn_rev,$jdk,$jobs,$svn_tag,$kuali_common,$kuali_common_latest,$shrub; 
} ## main

$env1_rice="ssh root\@env1.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env2_rice="ssh root\@env2.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env3_rice="ssh root\@env3.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env4_rice="ssh root\@env4.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env5_rice="ssh root\@env5.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$demo_rice="ssh root\@demo.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env7_rice="ssh root\@env7.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env8_rice="ssh root\@env8.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env9_rice="ssh root\@env9.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env10_rice="ssh root\@env10.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env11_rice="ssh root\@env11.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env12_rice="ssh root\@env12.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env13_rice="ssh root\@env13.rice.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";


$env1_ks="ssh root\@env1.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env2_ks="ssh root\@env2.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env3_ks="ssh root\@env3.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env4_ks="ssh root\@env4.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$staging_ks="ssh root\@staging.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env6_ks="ssh root\@env6.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env7_ks="ssh root\@env7.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env8_ks="ssh root\@env8.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$demo_ks="ssh root\@demo.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env10_ks="ssh root\@env10.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env11_ks="ssh root\@env11.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env12_ks="ssh root\@env12.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env13_ks="ssh root\@env13.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env14_ks="ssh root\@env14.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env15_ks="ssh root\@env15.ks.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";


$env1_ole="ssh root\@dev.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env2_ole="ssh root\@dev.docstore.ole.kuali.org cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
#$env3_ole="ssh root\@dev.rice2.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env3_ole="ssh root\@ec2-50-16-22-30.compute-1.amazonaws.com cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env4_ole="ssh root\@tst.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env5_ole="ssh root\@tst.docstore.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
$env6_ole="ssh root\@tst.rice2.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
#$env7_ole="ssh root\@env7.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
#$env8_ole="ssh root\@env8.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";
#$env9_ole="ssh root\@env9.ole.kuali.org  cat /usr/local/tomcat/webapps/ROOT/META-INF/MANIFEST.MF";

  printf "%-3s%-12s%-21s%-30s%-20s%-20s%-30s%-20s%-20s%-20s%-20s\n","ENV$delimitor","ENV Link$delimitor","Date$delimitor","Bundle Vers-Nexus$delimitor","SVN Rev$delimitor","JDK$delimitor","Jenkins Job$delimitor","SVN Tag$delimitor","kuali-common$delimitor","kuali-pom latest$delimitor","Shrub"; 

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
  @t=&changeEnvLink( $cmd );
  $env1 = $t[0]. $delimitor;
  &main(${cmd},$env_no);
}

@student = ( "env1_ks", "env2_ks", "env3_ks","env4_ks", "staging_ks","env6_ks", "env7_ks", "env8_ks","demo_ks","env10_ks","env11_ks","env12_ks","env13_ks","env14_ks","env15_ks");
$ssize_=@student;
for ( $index = 0; $index < $ssize_; $index++ )
{
  $project = "ks";
  $project1 = "student";
  $env_no = $index + 1 ;
  $env=$student[$index];
  $env1 = $env .$delimitor;
  $cmd = $$env;
  @t=&changeEnvLink( $cmd );
  $env1 = $t[0].$delimitor;
  #print "\ncmd: ",$cmd;
  &main(${cmd});
}


@ole = ( "env1_ole", "env2_ole", "env3_ole","env4_ole","env5_ole","env6_ole","env7_ole",,"env8_ole","env9_ole");
$ssize_=@ole;
for ( $index = 0; $index < $ssize_; $index++ )
{
  $project = "ole";
  $project1 = "ole";
  $env_no = $index + 1 ;
  $env=$ole[$index];
  $env1 = $env ."$delimitor";
  $cmd = $$env;
  @t=&changeEnvLink( $cmd );
  $env1 = $t[0]. "$delimitor";
  #print "\ncmd: ",$cmd;
  &main(${cmd});
}
