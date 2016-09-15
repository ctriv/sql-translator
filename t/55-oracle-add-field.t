#!/usr/bin/perl

use FindBin qw/$Bin/;
use Test::More;
use Test::SQL::Transpose;
use Test::Exception;
use Data::Dumper;
use SQL::Transpose;
use SQL::Transpose::Diff;

BEGIN {
    maybe_plan(2, 'SQL::Transpose::Parser::YAML', 'SQL::Transpose::Producer::Oracle');
}

my $schema1 = $Bin . '/data/oracle/schema_diff_b.yaml';
my $schema2 = $Bin . '/data/oracle/schema_diff_c.yaml';

open my $io1, '<', $schema1 or die $!;
open my $io2, '<', $schema2 or die $!;

my ($yaml1, $yaml2);
{
    local $/ = undef;
    $yaml1 = <$io1>;
    $yaml2 = <$io2>;
};

close $io1;
close $io2;

my $s = SQL::Transpose->new(from => 'YAML');
$s->parser->($s, $yaml1);

my $t = SQL::Transpose->new(from => 'YAML');
$t->parser->($t, $yaml2);

my $d = SQL::Transpose::Diff->new(
    {
        output_db     => 'Oracle',
        source_schema => $s->schema,
        target_schema => $t->schema,
    }
);

my $diff = $d->compute_differences->produce_diff_sql || die $d->error;

ok($diff, 'Diff generated.');
like($diff, '/ALTER TABLE d_operator ADD \( foo nvarchar2\(10\) NOT NULL \)/', 'Alter table generated.');
