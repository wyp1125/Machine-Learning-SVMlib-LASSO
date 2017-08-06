if($#ARGV<2)
{
print "Usage:tfsearch_file motif_file file_for_prediction\n";
exit;
}
open(input,"$ARGV[1]");
%sel_fea0=();
$i=0;
while($line=<input>)
{
if($line=~/^ID/)
{
$i++;
@a=split(" ",$line);
$sel_fea0{$i}=$a[1];
}
}
print $i,"\n";
open(output,">$ARGV[2]");
print output "\,Sequence";
for($j=1;$j<=$i;$j++)
{
print output "\,$sel_fea0{$j}";
}
print output "\,Target\n";
$j=1;
open(input,"$ARGV[0]");
while($line=<input>)
{
chomp($line);
if($line ne "")
{
print output $j++,"\,",read_mast2($line),"\,1\n";
}
}
sub read_mast2
{
my @aa="";
my %seq=();
my $key;
foreach $key (keys %sel_fea0)
{
$seq{$key}=0;
}
@aa=split(" ",$_[0]);
foreach (my $ii=1;$ii<=$#aa;$ii++)
{
if ($aa[$ii]=~/[\w\d\+\-]+:[\w\d\+\-\.]+:(\d+)/ )
{
                      if(exists $seq{$1})
                       {
                        $seq{$1}++;
                       }
}
}
my $fea=$aa[0];
        foreach $key( sort {$a <=> $b} keys %seq ){
               $fea=$fea."\,".$seq{$key};
        }
return $fea;
}
