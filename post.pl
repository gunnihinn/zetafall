#!/usr/bin/env perl

use v5.18;
use strict;
use warnings;

use DDP;

sub main {
    my (@args) = @_;

    say create_post($args[0]);

    return 0;
}

sub create_post {
    my ($markdown_filename) = @_;

    my ($title, @lines) = parse_markdown($markdown_filename);
    my $time = timestamp();
    my $json = encode_json($title, $time, @lines);
    chomp $json;

    return $json;
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

sub encode_json {
    my ($title, $timestamp, @lines) = @_;

    my $payload = {
        Title => $title,
        Timestamp => $timestamp,
        Content => join("\\n", @lines),
    };

    # JSON::PP exports a function called encode_json; require here to avoid
    # name collision problems
    require JSON::PP;
    my $coder = JSON::PP->new->pretty;

    return $coder->encode($payload);
}

main @ARGV if @ARGV;
