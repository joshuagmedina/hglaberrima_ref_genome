#!/usr/bin/perl
# Print a list of protein records shorter than a length cutoff (default 20 aa).
# Used to audit the EVM protein set before UniProt BLAST. Does NOT modify
# the input FASTA — it only reports IDs and lengths to STDOUT.
#
# Usage: perl extract_short_sequences.pl proteins.fa [length_cutoff]
use strict;
use warnings;

my $file   = $ARGV[0] or die "usage: $0 <proteins.fa> [cutoff]\n";
my $cutoff = defined($ARGV[1]) ? $ARGV[1] : 20;

open(my $fh, '<', $file) or die "Cannot open $file: $!";

my ($id, $seq) = ("", "");
while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /^>(\S+)/) {
        _emit($id, $seq, $cutoff) if $id ne "";
        $id = $1;
        $seq = "";
    } else {
        $seq .= $line;
    }
}
_emit($id, $seq, $cutoff) if $id ne "";
close $fh;

sub _emit {
    my ($id, $seq, $cutoff) = @_;
    my $len = length($seq);
    print "$id\t$len\n" if $len < $cutoff;
}
