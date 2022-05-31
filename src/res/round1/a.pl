# Opening the file
open(FH, "map-5")or die "Sorry!! couldn't open";
print("Reading file\n");
$i =0;
# Reading the file till FH reaches EOF
while(<FH>)
{
	# Printing one line at a time
	next if($_ !~ /SUM/);
	$i++;
	last if($i>60);
	$data = $_;
	$data =~ tr/ +/ /;
	@arr = split(' ',$data);
	if($data =~ /Gbit/){
		$arr[5] *= 1024;
	}
	print "$i $arr[5]\n";

}
close;
