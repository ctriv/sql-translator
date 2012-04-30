#!/usr/bin/perl
# vim: set ft=perl:

use strict;
use Test::More;
use Test::SQL::Translator qw(maybe_plan);

use SQL::Translator::Schema::View;
use SQL::Translator::Schema::Table;
use SQL::Translator::Producer::SQLite;
$SQL::Translator::Producer::SQLite::NO_QUOTES = 0;

{
  my $view1 = SQL::Translator::Schema::View->new( name => 'view_foo',
                                                  fields => [qw/id name/],
                                                  sql => 'SELECT id, name FROM thing',
                                                  extra => {
                                                    temporary => 1,
                                                    if_not_exists => 1,
                                                  });
  my $create_opts = { no_comments => 1 };
  my $view1_sql1 = [ SQL::Translator::Producer::SQLite::create_view($view1, $create_opts) ];

  my $view_sql_replace = [ 'CREATE TEMPORARY VIEW IF NOT EXISTS "view_foo" AS
    SELECT id, name FROM thing' ];
  is_deeply($view1_sql1, $view_sql_replace, 'correct "CREATE TEMPORARY VIEW" SQL');


  my $view2 = SQL::Translator::Schema::View->new( name => 'view_foo',
                                                  fields => [qw/id name/],
                                                  sql => 'SELECT id, name FROM thing',);

  my $view1_sql2 = [ SQL::Translator::Producer::SQLite::create_view($view2, $create_opts) ];
  my $view_sql_noreplace = [ 'CREATE VIEW "view_foo" AS
    SELECT id, name FROM thing' ];
  is_deeply($view1_sql2, $view_sql_noreplace, 'correct "CREATE VIEW" SQL');
}
{
    my $create_opts;

    my $table = SQL::Translator::Schema::Table->new(
        name => 'foo_table',
    );
    $table->add_field(
        name => 'foreign_key',
        data_type => 'integer',
        default_value => 1,
    );
    my $constraint = SQL::Translator::Schema::Constraint->new(
        table => $table,
        name => 'fk',
        type => 'FOREIGN_KEY',
        fields => ['foreign_key'],
        reference_fields => ['id'],
        reference_table => 'foo',
        on_delete => 'RESTRICT',
        on_update => 'CASCADE',
    );
    my $expected = [ 'FOREIGN KEY ("foreign_key") REFERENCES "foo"("id") ON DELETE RESTRICT ON UPDATE CASCADE'];
    my $result =  [SQL::Translator::Producer::SQLite::create_foreignkey($constraint,$create_opts)];
    is_deeply($result, $expected, 'correct "FOREIGN KEY"');
}
{
   my $table = SQL::Translator::Schema::Table->new(
       name => 'foo_table',
   );
   $table->add_field(
       name => 'id',
       data_type => 'integer',
       default_value => 1,
   );
   my $expected = [ qq<CREATE TABLE "foo_table" (\n  "id" integer DEFAULT 1\n)>];
   my $result =  [SQL::Translator::Producer::SQLite::create_table($table, { no_comments => 1 })];
   is_deeply($result, $expected, 'correctly unquoted DEFAULT');
}

done_testing;
