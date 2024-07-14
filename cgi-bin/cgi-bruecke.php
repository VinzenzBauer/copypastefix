<?php
	//$json = system("cat left.json");
	$str_pass="echo \"{ }\" | perl ./copypaste_parser.pl pos";
	system($str_pass);
	//exec "./copypaste_parser.pl";
	//echo "Returncode: " .$result ."<br>";
	//echo "Ausgabe des Scripts: " ."<br>";
	//echo "<pre>"; print_r($out);
?>