#! /usr/bin/perl

#_* Used modules
#require 5;
use strict;
use warnings;
use diagnostics;
use Carp;

use Readonly;
use Getopt::Euclid;
use IO::Prompt;
use Error;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use App::Sqemu;

# ABSTRACT: Starts a qemu machine based on a configuration file.
# PODNAME: App::Sqemu

use version; our $VERSION = qv('0.01_00');

#_* Global variable.
our %QEMU = (default => "qemu");
our $QEMU_OPT = " ";

#_* Functions definition.
#_ > # _set_verbosity_level #######################
# Purpose: Choose the right variable for Log4perl.
# Input  : No Input
# Output : A number corresponding to the level.
# Throws : No Exception
#_ >
sub _set_verbosity_level {
    my $level = $ERROR;
    if ( $ARGV{'-d'} ) {
        $level = $DEBUG;
    } elsif ( $ARGV{'-v'} ) {
        $level = $INFO;
    }
    return $level;
}

#_ > # get_conf #######################
# Purpose: Read the conf's file
# Input  : $machine,$conf
# Output : \%conf
# Throws : No Exception
#_ >
sub get_conf {
    DEBUG('get_conf', @_);
    my( $machine, $conf ) = @_;
    open my $conf_hd, '<', $conf
        or die qq{Could'nt open "$conf": $!};
    my %conf_of;
    my $inside = 1;
    my $last = 'GENERAL';
    $conf_of{$last} = [];
    if (defined $ARGV{-O}) {
        $QEMU_OPT = " -kernel-kqemu -enable-kqemu ";
        $QEMU{default} = $QEMU{default} . $QEMU_OPT;
    }
    while (<$conf_hd>) {
        next if m/^\s*#/;
        next if m/^\s*$/;
        next if m/^description/;
        if (m/^system[^=]*=(.*)$/ and $last eq $ARGV{'-m'} ) {
            $QEMU{$last}="qemu-system-$1 $QEMU_OPT";
            next;
        }
        chomp;
        if (m/^\[([^]]+)/ ) {
            $last = $1;
            $conf_of{$last} = [];
            next;
        }
        # remove commentaries within a conf line.
        s/\s*([^=]+=[^#\s]*)\s*#.+/$1/;
        # Make sure that every line get 2 elements.
        my @conf_line = ('', '');
        unshift @conf_line, split /\s*=\s*/, $_, 2;
        my $i = 0;
        # each first element is the parameters name, and get a "-"
        @conf_line = map { $i++ % 2 eq 0 ? '-' . $_ : $_ }
            @conf_line;
        unshift @{$conf_of{$last}}, @conf_line[0..1];
    }
    return @{$conf_of{GENERAL}}, @{$conf_of{$machine}};
}

sub get_list {
    my $conf = shift;

    open my $conf_hd, '<', $conf
        or die qq{Could'nt open "$conf": $!};
    my $last = 'GENERAL';
    my %conf_of;
    $conf_of{$last} = "";
    while (<$conf_hd>) {
        my $cline = $_;
        if (m/^\[([^]]+)/ ) {
            $last = $1;
            $conf_of{$last} = "";
            next;
        }
        if ( $cline =~ m/^description[^=]*=(.*)$/ ) {
            $conf_of{$last} = ( $conf_of{$last} ne "" ? $conf_of{$last}."\n" : "" ) . $1;
        }
    }
    return %conf_of;
}

#_* Main program
sub main {
    Log::Log4perl->easy_init( _set_verbosity_level() );
    DEBUG("Starting sqemu.pl");
    my @args=();
    my @from_rc;
    my @conf_src = grep {defined and -e} ($ENV{SQEMURC}, $ENV{HOME} . qq{/.sqemu/config});
    my %listing;
    if (defined $ARGV{'-l'} or not $ARGV{'-m'}) {
        for my $conf (@conf_src) {
            %listing = get_list($conf);
        }
        for (keys %listing) {
            next if ! index $_,  "GENERAL";
            print "$_ => ".($listing{$_} eq "" ? "No description" : $listing{$_} ) . "\n";
        }
        exit 0;
    }
    for my $conf ( @conf_src ) {
        @from_rc = get_conf $ARGV{'-m'}, $conf;
        next;
    }
    $ENV{TMUX} = "";
    my $cmd_b = q{if ! `tmux has-session qemu 2>/dev/null`; then tmux new -d -s qemu 'sh -c "sleep 10 "'; fi};
    DEBUG('EXEC: '. $cmd_b );
    system($cmd_b);
    qx(sleep 1);                # let tmux time to create session
    my $cmd_t = join ' ', @from_rc;
    $cmd_t = "'". (defined $QEMU{$ARGV{'-m'}} ? $QEMU{$ARGV{'-m'}} : $QEMU{default} ) ." ".$cmd_t."'";
    @from_rc = ();
    unshift @from_rc, qw(tmux attach -t qemu \; neww -n ),$ARGV{'-m'};
    push @from_rc, $cmd_t, qw(\; detach);
    DEBUG("EXEC: ", join ' ', @from_rc);
    my $cmd_f = join ' ', @from_rc;
    system($cmd_f) unless $ARGV{'-d'};
    #  exec {$from_rc[0]} @from_rc;
    1;                          # True value for exit.
}
# when compile works, uncomment.
exit( &main ? 0 : 1 );

#_* End.
__END__

# Created on Mer 26 nov 15:13:28 2008
# Local Variables:
# mode: cperl
# allout-layout: ( -2 : 0 0 )
# coding: utf-8
# End:
