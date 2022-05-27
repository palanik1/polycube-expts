#!/usr/local/bin/perl

for ($count = 1 ; $count <= 100 ; $count++)
{
	$cmd = "sed \"s/mapwriter/mapwriter$count/\" mapwriter.yang | sed \"s/MapWriter/MapWriter$count/\"  > mapwriter$count.yang";
	print "$cmd\n";
	system($cmd);
	$str ="cmd=\"export POLYCUBE_BASEMODELS=/usr/local/include/polycube/datamodel-common/; sudo docker run -it --user `id -u` -v \$POLYCUBE_BASEMODELS:/polycube-base-datamodels -v /home/ebpfuser/trash:/input -v /home/ebpfuser/trash:/output polycubenetwork/polycube-codegen -i /input/mapwriter$count.yang -o /output/pcn-mapwriter$count\"\nret=\$(eval \$cmd)\necho \$ret";
	open (FH, '>', "cmd.sh");
	print (FH  $str);
	close(FH);
	`sh cmd.sh`;
}
