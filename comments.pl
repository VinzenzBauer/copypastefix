#!/usr/bin/perl -w

use strict;
use CGI::Carp qw(fatalsToBrowser);

read(STDIN, my $Daten, $ENV{'CONTENT_LENGTH'});
my @Formularfelder = split(/&/, $Daten);
my ($Feld, $Name, $Wert);
my %Formular;
foreach $Feld (@Formularfelder) {
  (my $Name, my $Wert) = split(/=/, $Feld);
  $Wert =~ tr/+/ /;
  $Wert =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $Wert =~ s/</&lt;/g;
  $Wert =~ s/>/&gt;/g;
  $Formular{$Name} = $Wert;
 }
print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">', "\n";
print "<html><head><title>CGI-Feedback</title></head>\n";
print "<body><h1>CGI-Feedback vom Programm <i>comments.pl</i></h1>\n";
print "<p><b>Name:</b> $Formular{AnwenderName}</p>\n";
print "<p><b>Kommentartext:</b> $Formular{Kommentartext}</p>\n";
print "</body></html>\n";