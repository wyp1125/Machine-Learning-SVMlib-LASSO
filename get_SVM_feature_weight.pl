if($#ARGV<1)
{
print "matrix_file model_file\n";
exit;
}
my %weight_vector;
%h=();
open(input,"$ARGV[0]");
$i=1;
while($line=<input>)
{
if($line=~/^MOTIF/)
{
chomp($line);
@a=split(" ",$line);
$h{$i}=$a[1];
$i++;
}
}
open ( READ, $ARGV[1]) || die "cannot open $model";
while ( <READ> ){
        chomp;
        if ( /^([\+\-\.\w\d]+)\s\d+:[\d\.\+\-\w]+/ )
        {
        #print $1,"\n";
        @aux = split;
                $weight = shift ( @aux );

                #all vectors start with 1:0
                shift ( @aux );
                foreach ( @aux ){
                        if ( /(\d+):([\d\.\+\-\w]+)/ ){
                               $weight_vector{$1} += $2*$weight;
                        }
                        else {
                                die "Error: $_!\n";
                        }
                }
        }
}
close ( READ );


@index = sort {$weight_vector{$b} <=> $weight_vector{$a}} keys %weight_vector;
$i = 1;
foreach $motif ( @index ){
      unless ( $h{$motif} ){
                die "No record for $motif!\n";
        }
        if($i<=30)
        {
        print "$motif\t$h{$motif}\t$weight_vector{$motif}\n";
        }
$i++;
}
