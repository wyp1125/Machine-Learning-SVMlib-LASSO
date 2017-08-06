if($#ARGV<3)
{
print "pos_tfsearch neg_tfsearch pos_lasso neg_lasso\n";
exit;
}
open(input,"$ARGV[0]");
open(output,">$ARGV[2]");
$j=0;
while($line=<input>)
{
chomp($line);
if($line ne "")
{
@a=split("\t",$line,2);
if($a[0]=~/(chr[\d\w]+)\:(\d+)-(\d+)/)
{
$id[$j]="$1.$2.$3";
print output "$id[$j]\t$a[1]\n";
$j++;
}
}
}
open(input,"$ARGV[1]");
open(output,">$ARGV[3]");
$j=0;
while($line=<input>)
{
chomp($line);
if($line ne "")
{
@a=split("\t",$line,2);
if($a[0]=~/(chr[\d\w]+)\:(\d+)-(\d+)/)
{
print output "matched.$id[$j]\t$a[1]\n";
$j++;
}
}
}

