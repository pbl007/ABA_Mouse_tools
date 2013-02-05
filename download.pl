 #!/usr/local/bin/perl
 open (MYFILE, 'imageSeriesList.txt');
 $count = 0;
 print `mkdir Data_ABA_format`;

 while (<MYFILE>) {
   print `mkdir temp`;
 	chomp;
 	$count++;
 	print "\nLine number: $count\n\n";
#   exit if ($count > 5) ; 
	$url = 'http://api.brain-map.org/grid_data/download/'."$_";
	print "$url\n";
   print `wget $url`;
   print `unzip $_ -d temp`;
   print `rm $_`;
   print `mv temp Data_ABA_format/$_`;
   #one second delay between downloads
	sleep(1)
 }
 close (MYFILE); 

#delete empty directories - some downloads will fail (404s)
`find . -empty -type d -delete`;
