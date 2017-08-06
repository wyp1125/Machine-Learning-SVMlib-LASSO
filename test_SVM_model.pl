#!/usr/local/bin/perl
use strict;
use warnings;
use Cwd 'abs_path';

unless ( $#ARGV == 3 ){
	die "usage: perl $0 pos neg seqs_in_model output\n";
}

my $pos = $ARGV[0];
my $neg = $ARGV[1];
my $model = $ARGV[2];

my $abs_path = "/home/wangy30/software";
chomp ( $abs_path );

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

my ( $data, $seqs, $scores );
my $i;

my @ttt=split("\/",$neg);

$data = $ARGV[3];

$seqs = get_data ( $pos, $neg, $data );

$scores = test_linearsvm ( $data, $model );
unless ( $#$seqs == $#$scores ){
	die "Error.  The number of sequences does not match the number of outputs!\n";
}

print "svm data: $data\n";


sub test_linearsvm {
	my $data = $_[0];
	my $model = $_[1];
	
	my $command;
	my $output;
	my @scores;

	$output = "$data.tmp";

	$command = "$SVMTEST $data $model $output";
	$command = `$command`;
	print "TEST:\n";
	print "$command";

	unless ( -e $output ){
		die "Error.  ", (caller(0))[3], ".  $command.\n";
	}

	open ( READ, $output ) || die "Cannot open $output!\n";
	while ( <READ> ){
		if ( /[\+\-\d]+\s[\+\-\d]+\s([\w\d\.\+\-]+)/ ){
			push ( @scores, $1 );
		}
	}
	close ( READ );

	`mv $output $data`;
	
	return ( \@scores );
}

sub get_data {
	my $pos = $_[0];
	my $neg = $_[1];
	my $data = $_[2];

	my @seqs;
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
				push ( @seqs, [$labels[$i], $1] );
			}
		}
		close ( READ );
	}

	close ( WRITE );

	return ( \@seqs );
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


