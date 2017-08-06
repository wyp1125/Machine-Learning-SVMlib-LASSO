#!/usr/local/bin/perl
if($#ARGV<2)
{
print "pos neg output_dir/prefix number\n";
exit;
}
open(input,"$ARGV[0]");
$m=$n=0;
while($line=<input>)
{
$ps[$m]=$line;
$m++;
}
open(input,"$ARGV[1]");
while($line=<input>)
{
$ng[$n]=$line;
$n++;
}
for($tt=0;$tt<$ARGV[3];$tt++)
{
@sel=ran_sel($m,$m);
for($ss=0;$ss<5;$ss++)
{
open(output1,">$ARGV[2].trn.pos.fea.$tt.$ss");
open(output2,">$ARGV[2].trn.neg.fea.$tt.$ss");
open(output3,">$ARGV[2].pre.pos.fea.$tt.$ss");
open(output4,">$ARGV[2].pre.neg.fea.$tt.$ss");
open(output5,">$ARGV[2].log.$tt.$ss");
for($xx=0;$xx<$m;$xx++)
{
if($xx>=$ss*$m/5 && $xx<($ss+1)*$m/5)
{
print output3 $ps[$sel[$xx]];
print output4 $ng[$sel[$xx]];
#for($gg=0;$gg<3;$gg++)
#{
#print output4 $ng[3*$sel[$xx]+$gg];
#}
print output5 $sel[$xx],"\n";
}
else
{
print output1 $ps[$sel[$xx]];
print output2 $ng[$sel[$xx]];
#for($gg=0;$gg<3;$gg++)
#{
#print output2 $ng[3*$sel[$xx]+$gg];
#}
}
}
}
}
sub ran_sel
{
my %h=();
my $tot=$_[0];
my $sel=$_[1];
my $size=0;
my @a="";
while($size<$sel)
{
$temp=int(rand($tot));
if(!exists $h{$temp})
{
$h{$temp}=1;
$a[$size]=$temp;
$size++;
}
}
return @a;
}
