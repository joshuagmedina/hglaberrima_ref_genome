#!/usr/bin/perl
# Consolidate fragmented 5' / 3' UTR entries from a BRAKER3-generated
# augustus_hints_with_utr.gtf into a single span per (transcript, UTR
# type, strand).
#
# Input : augustus_hints_with_utr.gtf
# Output: consolidated GTF on STDOUT (UTRs replaced with min-to-max spans)
#
# Usage : perl consolidate_utrs.pl augustus_hints_with_utr.gtf > consolidated.gtf
use strict;
use warnings;

my $filename = $ARGV[0];  # GTF file to process
open(my $fh, '<', $filename) or die "Cannot open file $filename: $!";

my %utr_data; # Store UTR data for consolidation
my @lines;    # Preserve original order; UTRs get placeholders

while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;
    my @fields = split "\t", $line;

    if ($fields[2] eq 'three_prime_UTR' || $fields[2] eq 'five_prime_UTR') {
        my ($transcript_id) = $line =~ /transcript_id "([^"]+)"/;
        my $key = join("_", $transcript_id, $fields[2], $fields[6]);
        push @{$utr_data{$key}}, \@fields;
        push @lines, $key;
    } else {
        push @lines, $line;
    }
}

# Collapse each (transcript, UTR type, strand) group to a min-max span
foreach my $key (keys %utr_data) {
    my ($min, $max);
    foreach my $entry (@{$utr_data{$key}}) {
        $min = $entry->[3] if !defined($min) || $entry->[3] < $min;
        $max = $entry->[4] if !defined($max) || $entry->[4] > $max;
    }
    my $consolidated = $utr_data{$key}[0];
    $consolidated->[3] = $min;
    $consolidated->[4] = $max;

    for (my $i = 0; $i < @lines; $i++) {
        if ($lines[$i] eq $key) {
            $lines[$i] = join("\t", @$consolidated);
            last;  # first occurrence only
        }
    }
}

foreach my $line (@lines) {
    print "$line\n";
}

close $fh;
