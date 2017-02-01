#!/usr/bin/env perl

use v5.18;
use strict;
use warnings;

use File::Basename;
use File::Temp;

use DDP;

my $BLOG = "$ENV{HOME}/Devel/golang/src/zetafall/blog";

sub main {
    my (@args) = @_;

    my %posts = map { $_ => 1 } map { basename($_) } glob("$BLOG/*.json");

    for my $arg (@args) {
        my $new_post = not exists $posts{basename($arg)};

        my $filename;
        if (not $new_post) {
            $filename = $arg;
        }

        my $action = ($new_post) ? \&create_post : \&edit_post;
        my $json = $action->($arg);
        write_post($json, $filename);
    }

    return 0;
}

sub write_post {
    my ($json, $filename) = @_;

    $filename = find_new_post_name() if not $filename;

    open my $fh, '>', $filename or die $!;
    print $fh $json;
    close $fh;

    return;
}

sub find_new_post_name {
    my @posts = glob("$BLOG/*.json");
    my $num = @posts;

    return sprintf("$BLOG/%s.json", $num+1);
}

sub create_post {
    my ($markdown_filename) = @_;

    my ($title, @lines) = parse_markdown($markdown_filename);
    my $time = timestamp();
    my $json = encode_json($title, $time, @lines);
    chomp $json;

    return $json;
}

sub edit_post {
    my ($json_filename) = @_;

    my $post = parse_json($json_filename);
    my $content = $post->{Content};
    $content =~ s/\\n/\n/g;

    my $fh = File::Temp->new( SUFFIX => '.md' );
    say $fh $post->{Title};
    say $fh "";
    say $fh $content;

    my $fname = $fh->filename();
    system("\$EDITOR $fname");

    my ($title, @lines) = parse_markdown($fname);
    my $json = encode_json($title, $post->{Timestamp}, @lines);

    return $json;
}

sub parse_json {
    my ($fn) = @_;

    local $/;
    open my $fh, '<', $fn or die $!;
    my $js = <$fh>;
    close $fh;

    say $js;

    require JSON::PP;
    my $json = JSON::PP->new->utf8;

    return $json->utf8(0)->decode($js);
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
