#!/usr/local/bin/perl
use strict;
use warnings;
use Cwd 'abs_path';

unless ( $#ARGV == 1 ){
	die "usage: perl $0 pos neg\n";
}

my $pos = $ARGV[0];
my $neg = $ARGV[1];

my $abs_path = "/home/wangy30/software";
our $SVMC = "$abs_path/libsvm/libsvm-2.9/svm-c";
our $SVMTRAIN = "$abs_path/libsvm/libsvm-2.9/svm-train";
our $SVMTEST = "$abs_path/libsvm/libsvm-2.9/svm-predict";

if ( ! -f $SVMC ){
	die "Error. Cannot find $SVMC!\n";
}
if ( ! -f $SVMTRAIN ){
	die "Error. Cannot find $SVMTRAIN!\n";
}
if ( ! -f $SVMTEST ){
	die "Error. Cannot find $SVMTEST!\n";
}
$SVMTRAIN = "$SVMTRAIN -t 0 ";

my $model ;

my @ttt=split("\/",$neg);

$model = "$pos.$ttt[$#ttt].svm_model";

get_data ( $pos, $neg, $model );

train_linearsvm ( $model );

print "model: $model\n";


sub train_linearsvm {
	my $data = $_[0];
	
	my $command;
	my ( $c, $grep, $weights, $svm_model );

	$svm_model = "$data.model";

	$grep = 'grep -P "^-1\s"';
	$command = `$grep $data | wc`;
	unless ( $command =~ /([\w\d\+\-\.]+)/ ){
		die "Error.  $command: no negative sequences!\n";
	}
	$weights = $1;
	$grep = 'grep -P "^1\s"';
	$command = `$grep $data | wc`;
	unless ( $command =~ /([\w\d\+\-\.]+)/ ){
		die "Error.  $command: no positive sequences!\n";
	}
	$weights = $weights / $1;

	$c = `$SVMC $data`;
	unless ( $c =~ /Default\strade-off\sc\s([\d\.\w\+\-]+)\./ ){
		die "$c: wrong format!\n";
	}
	$c = $1;

	$command = "$SVMTRAIN -v 10 -c $c -w1 $weights -q $data $svm_model";
	$command = `$command`;
	print "TRAIN:\n";
	print "$command";

	$command = "$SVMTRAIN -c $c -w1 $weights -q $data $svm_model";
	$command = `$command`;
	unless ( -e $svm_model ){
		die "Error.  ", (caller(0))[3], ".  $command.\n";
	}

	`mv $svm_model $data`;

	return ( $svm_model );
}

sub get_data {
	my $pos = $_[0];
	my $neg = $_[1];
	my $data = $_[2];

	my ( $i, @labels, @files );

	@labels = (1, -1);
	@files = ( $pos, $neg );
	
	open ( WRITE, ">$data" ) || die "cannot open $data!\n";
	
	for ( $i=0; $i<=$#labels; $i++ ){
		open ( READ, $files[$i] ) || die "Cannot open $files[$i]!\n";
		while ( <READ> ){
			chomp;
			if ( /^#/ ){
				next;
			}
			elsif ( /^>([\w\d]+:[\w\d]+:\d+-\d+)\s+/ ){
				read_MAST ( $labels[$i], $1, $', *WRITE );
			}
		}
		close ( READ );
	}

	close ( WRITE );

	return;
}

sub read_MAST {
	my $label = $_[0];
	my $header = $_[1];
	my $seq = $_[2];
	local (*WRITE) = $_[3];

	my ( $length, @seq, %seq ) ;
	
	unless( $header =~ /^[\w\d]+:[\w\d]+:(\d+)-(\d+)/ ){
		die "Error.  $header!\n";
	}
	$length = abs($1 - $2);
	

	@seq = split ( /\s/, $seq  );
	foreach ( @seq ){
		if ( /[\w\d\+\-]+:[\w\d\+\-\.]+:(\d+)/ ){
			$seq{$1}++;
		}
		else {
			die "Error.  $_!\n";
		}
	}

	print WRITE "$label\t";
	foreach $seq( sort {$a <=> $b} keys %seq ){
		printf WRITE ( "%d:%.4f ", $seq, $seq{$seq}/$length );
	}
	print WRITE "\n";

	return;
}

