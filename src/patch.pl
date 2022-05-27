#!/usr/local/bin/perl

for ($count = 1 ; $count <= 100 ; $count++)
{

	$cmd = "perl -p -e 's/(?<=ctxwriter)/$count/gi' Ctxwriter.cpp > /home/ebpfuser/trash/ctx/pcn-ctxwriter$count/src/Ctxwriter$count.cpp";
	system($cmd);
	print("$cmd\n");
	$cmd = "perl -p -e 's/(?<=ctxwriter)/$count/gi' Ctxwriter.h > /home/ebpfuser/trash/ctx/pcn-ctxwriter$count/src/Ctxwriter$count.h";
	system($cmd);
	print("$cmd\n");
	$cmd = "perl -p -e 's/(?<=ctxwriter)/$count/gi' Ctxwriter_dp.c > /home/ebpfuser/trash/ctx/pcn-ctxwriter$count/src/Ctxwriter$count\_dp.c";
	system($cmd);
	print("$cmd\n");
}
