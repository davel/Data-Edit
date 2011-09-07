package Data::Edit::vimdiff;
use Moose;
use File::Temp qw/ tempfile /;

with qw/ Data::Edit::Role::Editor /;

sub edit {
    my ($self, $file) = @_;
    my (undef, $fn) = tempfile( SUFFIX => ".yml");
    system("cp", "--", $file, $fn) == 0 or die "cannot copy!";

    chmod 0400, $fn;
    system($self->path, $fn, $file) or die "editor failed";
    unlink($fn) or warn "Could not remove '$fn': $!";
    return;
}

1;
