#!/usr/bin/env perl

use v5.18;
use strict;
use warnings;

use DDP;

sub main {
    my (@args) = @_;

    my ($title, @lines) = parse_markdown($args[0]);
    my $time = timestamp();
    say json($title, $time, @lines);

    return 0;
}

sub parse_markdown {
    my ($fn) = @_;

    open my $fh, '<', $fn or die $!;

    my $title = <$fh>;
    chomp $title;

    my @lines = ();
    while (my $line = <$fh>) {
        chomp $line;
        push @lines, $line;
    }

    close $fh;

    while (not $lines[0]) {
        shift @lines;
    }

    while (not $lines[@lines-1]) {
        pop @lines;
    }

    return ($title, @lines);
}

sub timestamp {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;

    return sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", $year, $mon, $mday, $hour, $min, $sec);
}

sub json {
    my ($title, $timestamp, @lines) = @_;

    my $content = join("\\n", @lines);

    my $js = "{\n";
    $js .= "    \"Title\": \"$title\",\n";
    $js .= "    \"Timestamp\": \"$timestamp\",\n";
    $js .= "    \"Content\": \"$content\"\n";
    $js .= "}";

    return $js;
}

main @ARGV if @ARGV;
