use strict;
use warnings;
use version 0.77; our $VERSION = qv("v0.01_00");
package App::Sqemu;
use Getopt::Euclid;

=for podder
Use perldoc -MPod::Simple::Text <pod file> if you get:
"Unknown command paragraph: =encoding utf8"

=encoding utf8

=head1 NAME

sqemu.pl - Start a qemu machine based on a configuration file.

=head1 VERSION

This documentation refers to "sqemu.pl" version 0.01_00

=head1 USAGE

sqemu.pl [options]

=head1 REQUIRED ARGUMENTS

=over


=back

=head1 OPTIONS

=over

=item <qemu args>...

You can specify arbitrary args to sqemu, they will be passed "as-is"
to qemu.

=item -m <machine>

The machine's virtual name.

=item  -v

Increases the verbosity of the program.

=item -d

Switch to Debug mode.

=item -l

List all defined machines

=item -O

Optimize flag

=item --version

=item --usage

=item --help

=item --man

Those four last options print the usual program information.

=back

=head1 DESCRIPTION

=head1 DIAGNOSTICS

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

Look for it configuration in those place in that order:
 1. on the command line (args are passed to qemu);
 2. on the file pointed by SQEMURC environmental var;
 3. on the file $HOME/.sqemu/config

If it finds nothing, aborts.

=head1 DEPENDENCIES

=over

=item L<Readonly>

=item L<Getopt::Euclid>

=item L<IO::Prompt>

=item L<Error>

=item L<Log::Log4perl>

=back



=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to Sathlan L<E<lt>mypublicaddress-code@NOSPAM yahoo.comE<gt>>.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Sathlan C<E<lt>mypublicaddress-code@NOSPAM yahoo.comE<gt>>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008 Sathlan All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

1;
