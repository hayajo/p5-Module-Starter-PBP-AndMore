package Module::Starter::PBP::AndMore;

use strict;
use warnings;
use autodie;

our $VERSION = '0.01';

use parent qw/Module::Starter::PBP/;

use File::Spec;
use File::Find;
use IO::File;

use constant IGNORE_FILES => [
    ['Build.PL'],     ['Makefile.PL'],
    ['README'],       ['Changes'],
    ['Module.pm'],    [ 't', 'pod-coverage.t' ],
    [ 't', 'pod.t' ], [ 't', 'perlcritic.t' ],
];

sub create_modules {
    my $self = shift;
    my @files = $self->SUPER::create_modules(@_);
    my @ignore_files
        = map { File::Spec->catfile( $self->{template_dir}, @$_ ) => 1 } @{ IGNORE_FILES() };
    push @files, $self->_more_files(@ignore_files);
    return @files;
}

sub create_ignores {
    my $self = shift;
    my $type  = $self->{ignores_type};
    $type = ["$type"] if ( ref $type ne 'ARRAY' );
    my %names = (
        generic  => 'ignore.txt',
        cvs      => '.cvsignore',
        git      => '.gitignore',
        manifest => 'MANIFEST.SKIP',
    ); # Module::Starter::Simple#create_ignores

    my @no_exists;
    for my $t (@$type) {
        next unless ( $names{$t} );
        my $ignores_template = File::Spec->catfile( $self->{template_dir}, $names{$t} );
        if ( -e $ignores_template ) {
            $self->_apply_template($ignores_template);
        }
        else {
            push @no_exists, $t;
        }
    }
    $self->{ignores_type} = \@no_exists;

    $self->SUPER::create_ignores();
}

sub _more_files {
    my $self = shift;
    my $ignore_files = +{ map { $_ => 1 } @_ };

    my @files;
    find +{
        wanted => sub {
            my $file = $File::Find::name;
            return if ( $ignore_files->{$file} );
            push @files, $self->_apply_template($file);
        },
        no_chdir => 1,
    }, $self->{template_dir};

    return @files;
}

sub _apply_template {
    my ($self, $file) = @_;
    my $rel_file_path
        = File::Spec->abs2rel( $file, $self->{template_dir} );
    my $dest_file_path
        = File::Spec->catdir( $self->{basedir}, $rel_file_path );
    if ( -d $file ) {
        mkdir $dest_file_path unless ( -e $dest_file_path );
        return;
    }
    my $buf = $self->_load_and_expand_template($rel_file_path);
    my $io = IO::File->new( $dest_file_path, 'w' );
    $io->print($buf);
    $io->close;
    return $rel_file_path;
}

1;
__END__

=head1 NAME

Module::Starter::PBP::AndMore - Create a module using Module::Starter::PBP with more templates.

=head1 SYNOPSIS

Set up as well as the L<Module::Starter::PBP/"SYNOPSYS">.

Then add some template files in template_dir.

  # e.g. - added template '.shipit'
  % cd <template_dir>
  % echo "steps = FindVersion, ChangeVersion, CheckChangeLog, DistTest, Commit, Tag, MakeDist, UploadCPAN" > .shipit

Then execute "module-starter" on the command-line as usual ...

  % module-starter --module=Your::New::Module

=head1 DESCRIPTION

Module::Starter::PBP::AndMore adds a simple template to L<Module::Starter::PBP>.

=head1 METHODS

=head2 create_modules

This method create a starter module file for each module named in @modules.

Then reads in the template files and directories, populates them. The module template directory is found by checking the config option "template_dir".

=head2 create_ignores

This creates a text file for use as MANIFEST.SKIP, .cvsignore, .gitignore, or whatever you use.

Already declared ignore files in "template_dir", they are populated.

=head1 Template format

The template files are supported placeholders similar to L<Module::Starter::PBP/"Template-format">.

see L<Module::Starter::PBP/"Template-format">.

=head1 AUTHOR

hayajo E<lt>hayajo@cpan.orgE<gt>

=head1 SEE ALSO

L<Module::Starter::PBP>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
