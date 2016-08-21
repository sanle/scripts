#! /usr/bin/perl

use strict;
use warnings;

use 5.010;

require LWP::UserAgent;
require HTTP::Response;
use XML::RSS;
use Data::Dumper;
use utf8;

my $ua = LWP::UserAgent->new;

binmode(STDOUT,':utf8');

my @config;

&readconf();

my $response;

foreach my $rssconf (@config)
{
	$response = $ua->get($rssconf->{'link'});

	if($response->is_success)
	{
		my $item;
		my $rss = new XML::RSS;
		$rss->parse($response->content);
		foreach $item (@{$rss->{'items'}})
		{
			foreach  my $pattern (@{$rssconf->{'patterns'}})
			{
				if($item->{'title'} =~ /$pattern/i)
				{
					print $item->{'title'}."\n".$item->{'link'}."\n"
				}
			}
		}
	}
	else
	{
		die $response->status_line;
	}
}

sub readconf
{
	open FIN , "< exuad.conf" or die("Cannot read confif file");
	binmode(FIN,':utf8');
	my @strings = <FIN>;
	close FIN;
	my $fl = 0;
	my $index = -1;
	foreach my $string (@strings)
	{
		chomp $string;
		if($string eq "#")
		{
			$fl =1;
			next;
		}
		if($fl == 1)
		{
			$index++;
			push @config, {"link"=>$string, "patterns" =>[]};
			$fl = 0;
		}
		else
		{
			push $config[$index]->{"patterns"}, $string;
		}
	}
	
}
