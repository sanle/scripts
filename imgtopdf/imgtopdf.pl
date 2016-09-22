#! /usr/bin/perl

use 5.010;
use strict;
use warnings;

use File::Find;
use Image::Info qw(image_info dim);
use PDF::API2;

my @files;

find({wanted=>\&to_file_array,no_chdir=>1},@ARGV);
&process;
#######################

sub to_file_array
{
	return if !&check_name($_);
	push @files, $_;
}

sub process
{
	my $pdf = PDF::API2->new(
		-file	=> 'out.pdf'
	);
	$pdf->mediabox('A4');
	my $my_y = 0;
	my $page;
	foreach my $file (sort @files)
	{
		my $info = image_info($file);
		if (my $error = $info->{error})
		{
			die "Can`t parse image info: $error\n";
		}
		my ($w, $h) = dim($info);
		say $file." ".$w." ".$h;
		$my_y-=$h;
		if($my_y< 0)
		{
			$page = $pdf->page;
			$my_y=841-$h;
		}
		my $gfx = $page->gfx;
		my $image = $pdf->image_gif($file);
		$gfx->image($image,20,$my_y);
	}
	$pdf->save();
	$pdf->end();
}

sub check_name
{
	if ($_[0]=~/\.gif/io)
	{
		return 1;
	}
	0;
}
