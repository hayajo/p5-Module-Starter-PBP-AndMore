use strict;
use autodie;
use Test::More tests => 2;

use Module::Starter qw/Module::Starter::PBP::AndMore/;
use File::Temp;
use File::Basename qw/dirname/;

my $tmpdir  = File::Temp->newdir;
my $starter = Module::Starter->new(
    dir          => $tmpdir,
    builder      => 'Module::Build',
    modules      => [qw/Foo::Bar/],
    email        => 'yourname@example.com',
    author       => 'yourname',
    force        => 1,
    ignores_type => [],
);
$starter->{template_dir} = File::Spec->rel2abs( File::Spec->catdir(dirname(__FILE__), '.templates') );
$starter->create_distro;

my $additional = File::Spec->catfile($tmpdir, qw/foo bar buz.txt/);
ok -f $additional;

open my $fh, '<', $additional;
my $content = do { local $/; <$fh> };
chomp $content;
is $content, $starter->{distro};
