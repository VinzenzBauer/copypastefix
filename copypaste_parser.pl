#!/usr/bin/perl -w
use strict;
use warnings;
use Term::ANSIColor;
use Data::Dumper qw(Dumper);
use JSON;  
no warnings;

### SUBS
sub uniq { 
	my %seen; 
	grep !$seen{$_}++, @_ 
}

# writeArrayToFile(@newpos, "copypaste_pos.txt");
sub writeArrayToFile{		# write to entities-list saved on the server
	my @a = @{$_[0]};
	my $filename = $_[1] || "copypaste_pos.txt";
	
	# write array to txt file
	open my $handle, ">$filename" or die "Cannot open output
		+.txt: $!"; 
		foreach my $ent (@a) {
			print $handle $ent . "\n";
		}
	close $handle;
}

# my @pos = readArrayFromFile("copypaste_pos.txt", "pos");
sub readArrayFromFile{		# reading from entities-list saved on the server
	my $filename = shift or die "dont know what to read!";
	my $param = shift || 'pos';
	
	if (-e "copypaste_$param.txt"){
		open my $handle, '<', $filename or die "Can't open < $filename!";
		chomp(my @ent = <$handle>);
		close $handle;
		
		return uniq(@ent);
	}
}

#sub writeArrayToJson{		# fixing and writing the json-basefile
#	my @a = @{$_[0]};
#	my $filename = $_[1];
#}

# my @basefileArray = readArrayFromJson($json);
sub readArrayFromJson{		# reading from json-basefile
	my $json = shift;
	
	my @ent;
	# read json input and add to array
	my $decoded_json = decode_json( $json );
	my $ARent = $decoded_json->{'entities'};
	foreach my $ent (@$ARent) {
		push(@ent, $ent->{'prefabname'});
	}
	# filter array
	return uniq(@ent);
}

# if (isValidJson($json) == 0) { print "json invalid"; return 0; }
sub isValidJson{
	my $json = shift;
	# check if given json is valid at all
	my $json_out = eval { decode_json($json) };
	if ($@)	{ return 0; }
	return 1;
}

# my @diff = arrayMinusArray(@neg, @pos);
sub arrayMinusArray{
	my @a = @{$_[0]};
	my @b = @{$_[1]};	
	return grep{ not $_ ~~ @b } @a;
}

# printCopyPaste(@diff, "pos");
sub printCopyPaste{
	my @a = @{$_[0]};
	my @b = @{$_[1]};
	my $param = $_[2] || 'pos';

	print color("green"), "========= Thank you for reporting ==========", color("reset"), "\n";
	if ($param eq "pos"){
		print color("green"), "========= So far we could identify these " , scalar @a, " possible problems ==========", color("reset"), "\n";
		print Dumper @a;
		print color("green"), "========= After your report, these " , scalar @b, " remain ==========", color("reset"), "\n";
		print Dumper @b;
	}else{
		print color("green"), "========= Your basefile contains following known possible problematic objects " , scalar @a, " remain ==========", color("reset"), "\n";
		print Dumper @a;
		print color("green"), "========= Your basefile contains following unknown possible problematic objects " , scalar @a, " remain ==========", color("reset"), "\n";
		print Dumper @b;
	}
}

# removeAEntitiesFromJson(\@basefileMpos,$json);
sub removeAEntitiesFromJson{
	my @a = @{$_[0]};
	my $json = $_[1];

	print color("red"), "========= json parsing ==========", color("reset"), "\n";
	my $decoded_json = decode_json( $json );
	print $decoded_json->{'protocol'}{'version'}{'Patch'} ."\n";
	#print "entities 2: ",
    #  $decoded_json->{'protocol'}{'version'}{'Patch'},
	#  $decoded_json->{'entities'}[2]{'prefabname'},
    #  "\n";
	
	
	# write array to txt file
	open my $handle, ">cleaned_file" or die "Cannot open output.txt: $!"; 

	foreach my $key (keys %$decoded_json) {
		if ($key eq "entities"){
			my $Aent = $decoded_json->{'entities'};
			foreach my $ent (@$Aent) {
				#print $ent->{'prefabname'} . "\n";
				#push(my @ent, $ent->{'prefabname'});
			}
		}else{
			print $handle $decoded_json . "\n";
			#print "$decoded_json\n";
		}
	}
	
	close $handle;
	
	#my @filtered = grep { $_->{entities}->{prefabname} ne 'assets/prefabs/building core/wall/wall.prefab' } @$decoded_json;
	#print Dumper @filtered;
	
}

# =========================== HAUPT ROUTINE ===========================
# Terminologien: 	json (basefile input); 
#					array (temporary hold entities storage); 
#					file (perma saved list of neg and pos entities)
# in basefile (json)
# in basefilestatus (parameter: pos neg)
# ----
# array of basefile entities
# array of pos entities
# array of neg entities
# parameter pos -> ty for feeding the database
#				-> show problematic entities: array (neg - pos)
# parameter neg -> array neg += array basefile entities 
#				-> array neg -= array pos
#				-> show problematic entities: array (basefile - pos)
#				-> choice: delete single or all entities from basefile
sub main{
	my $json = shift || '{ }';
	my $param = shift || 'pos';

	if (isValidJson($json) == 0) { print "json invalid"; return 0; }
	
	my @basefileArray = readArrayFromJson($json);
	my @pos = readArrayFromFile("copypaste_pos.txt", "pos");
	my @neg = readArrayFromFile("copypaste_neg.txt", "neg");
	
	if ($param eq "pos"){
		my @negMpos  			= arrayMinusArray(\@neg, \@pos);
		my @negMposMbasefile 	= arrayMinusArray(\@negMpos, \@basefileArray);
		printCopyPaste(\@negMpos, \@negMposMbasefile, "pos");
		
		my @newpos = (@pos, @basefileArray);
		writeArrayToFile(\@newpos, "copypaste_pos.txt");
	}else{
		my @basefileMpos 		= arrayMinusArray(\@basefileArray, \@pos);
		my @basefileMposMneg  	= arrayMinusArray(\@basefileMpos, \@neg);
		printCopyPaste(\@basefileMpos, \@basefileMposMneg, "neg");
		
		removeAEntitiesFromJson(\@basefileMpos,$json);
	}
}
# =========================== HAUPT ROUTINE ===========================
### INPUT PARAMS
my $PIPE = "";
## READ WHOLE FILE
if (-t STDIN) { die "No Input to be analized given\n" }
foreach my $line ( <STDIN> ) {
    $PIPE .= $line;
}
## POS or NEG
my $param = shift || 'pos';
### PROGRAM FLOW
main($PIPE, $param);

### END
1