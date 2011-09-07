package Data::Edit;

use 5.010001;
use strict;
use warnings;

require Exporter;
use File::Spec;
use YAML::Any;
use File::Temp qw/ tempfile /;
use Data::Edit::vimdiff;
use Data::Edit::editor;
use Cwd;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Data::Edit ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
    edit_structure
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.01';

sub edit_structure {
    my ($structure, $name) = @_;

    my $last_error;
    my $out;

    do {
        my ($fh, $fn) = tempfile( SUFFIX => ".yml" );
        if (defined $last_error) {
            print $fh map { "# $_\n" } split(/\n/, $last_error);
        }
        print $fh map { "# $_\n" } split(/\n/, $name);


        print Dump($structure);
        close $fh;

        my $ed = find_editor();
        $ed->edit($fn);

        local $@;
        eval {
            $out = Load($fn);
        };
        unlink($fn) or warn "Could not delete '$fn': $!";

        $last_error = $@;

    } while (defined $last_error);

    return $out;
}

sub find_editor {
    my $ed = $ENV{VISUAL} || $ENV{EDITOR};

    # Debian / Ubuntu magic
    unless ($ed) {
        $ed = "/usr/bin/editor";
        if (-l $ed) {
            $ed = Cwd::realpath($ed);
        }
    }

    my ($vol, $dir, $file) = File::Spec->splitdir($ed);

    if ($file eq 'vim') {
        if (-x (my $vimdiff = File::Spec->catpath($vol, $dir, $file))) {
            return Data::Edit::vimdiff->new( path => $vimdiff );
        }
    }
    return Data::Edit::editor->new( path => $ed );
}

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Data::Edit - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Data::Edit;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Data::Edit, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Dave Lambley, E<lt>davel@state51.co.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Dave Lambley

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
