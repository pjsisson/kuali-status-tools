#!/usr/bin/perl 
chomp(@ARGV); $env=$ARGV[0];
$project=$ARGV[1];
$sizec = length($env);
$size_ = int($sizec);

sub main
{
$search_pattern = "/var/lib/jenkins/workspace/*/config.xml";
$config_file_list = "/tmp/config_file_list.txt";
`ssh ubuntu\@ci.rice.kuali.org \"ls /var/lib/jenkins/workspace/*/config.xml\" > $config_file_list`;
open ( cf,  "<$config_file_list"); (@CF =<cf>); close (cf);
$index=0;
foreach $file (@CF)
{
   chomp($file);
   @arrayfile = split(/\//, $file);
   $filename = $arrayfile[5];
   $jobname = $arrayfile[5];
   $cmd = "grep \"disabled>true\" $file";
   @line = `ssh ubuntu\@ci.rice.kuali.org $cmd`;
   chomp(@line);
   if ( $line[0] ne "" ){ next; }
   if ( $jobname !~ /^$project/  ){ next; }

   #print "\njobname: $jobname";
   $jobsearch_start = "/var/lib/jenkins/workspace/$jobname/builds";
   $status_dir = `ssh ubuntu\@ci.rice.kuali.org \"ls -tr $jobsearch_start | tail -1\"`; 
   chomp( $status_dir);
   if ( -e "$jobsearch_start/$status_dir/build.xml" )
   {
   $status = "ssh ubuntu\@ci.rice.kuali.org egrep \"<\/result>\" $jobsearch_start/$status_dir/build.xml";
   chomp( $status);
   }
   $cmd = "grep \"env=$env\" $file";
      @line = `ssh ubuntu\@ci.rice.kuali.org $cmd`;
      #print "\n$file: ",@line;
      $found = 0;
      if (( @line > 0))
        {$found = 1;}
      if ( $found )
      { 
        foreach $entry (@line)
        {
          $comment = substr($entry,0,1);
          if ( $comment eq "#" ){ next; }
          @parts = split(/env=/,$entry);  #find what's after env= 
          #print "\nparts[0] ", $parts[0], "parts[1] ", $parts[1], "size_: ",$size_;
          $env_found = int(substr($parts[1], 0, 2));
          $env = int($env);
          #print "\nenv_found: $env_found"; 
          #print "\n parts[0] ", $parts[0];
          #if ( $project !~  "ole" )
          #{ @second_parts=split(/</,$parts[1]); } #knock off any xml marks, take first occurance 
          #else
          #{ @second_parts=split(/ -Dkuali-deploy/,$parts[1]); } #take first occurance 

          #$second_parts[0] =~ s/\s+//g; #get rid of any trailing spaces
          #if ( $second_parts[0] eq $env ) 
          if ( $env_found == $env ) 
          {  
             
             #print "\nDoes $env_found eq $env";
             @jobx = split(/:/,$entry,1);
            chomp(@jobx);
            #print "\n", $filename," ",@jobx;
            if ( -e "$jobsearch_start/$status_dir/build.xml" )
             { $statusResults = `$status`; 
               chomp( $statusResults ); }
             else
             { $status = "<>building</>";  }
            if (( $filename =~ $project) )
              { (@statusOutcome) = split(/>|</,$statusResults);
            print $comma;
            #print "<a href=\"http:\/\/ci.rice.kuali.org\/job\/$jobname\">$jobname<\/a>($statusOutcome[2])"; 
            print "[".$jobname."|http:\/\/ci.rice.kuali.org\/job\/$jobname]"."($statusOutcome[2])"; 
           $comma = " \\\\ ";  }
          }
         }
      }
}
 }
&main();
