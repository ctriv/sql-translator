#!/usr/bin/perl
use strict;

use FindBin qw/$Bin/;
use Test::More;
use Test::SQL::Transpose;
use Test::Exception;
use Data::Dumper;
use SQL::Transpose;
use SQL::Transpose::Schema::Constants;

BEGIN {
    maybe_plan(2, 'SQL::Transpose::Parser::YAML', 'SQL::Transpose::Producer::Oracle');
}

my $yamlfile = "$Bin/data/oracle/schema_with_options.yaml";

my $sqlt;
$sqlt = SQL::Transpose->new(
    show_warnings     => 0,
    add_drop_table    => 0,
    producer_args     => {'delay_constraints' => 1},
    quote_table_names => 0,
    quote_field_names => 0,
);

my $sql_string = $sqlt->translate(
    from     => 'YAML',
    to       => 'Oracle',
    filename => $yamlfile,
);

ok($sql_string,                                               'Translation successfull');
ok($sql_string =~ /ADD CONSTRAINT pk_d_operator PRIMARY KEY/, 'constraints delayed');
