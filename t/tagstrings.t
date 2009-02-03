#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';
use String::TagString;

my @tagstrings = (
  [ ''                   => {} ],
  [ 'foo'                => { foo => undef } ],
  [ 'foo bar'            => { foo => undef, bar => undef } ],
  [ '@foo bar'           => { '@foo' => undef, bar => undef } ],
  [ 'foo+bar'            => { foo => undef, bar => undef } ],
  [ 'foo baz:peanut bar' => { foo => undef, bar => undef, baz => 'peanut' } ],
  [ 'foo baz: bar'       => { foo => undef, bar => undef, baz => ''       } ],
  [ 'bad()tag foo bar'   => undef ],
  [ 'bad:tag|value foo'  => undef ],

  [ 'foo baz:"peanut butter" bar  '  => { foo => undef, bar => undef, baz => 'peanut butter' } ],
  [ 'foo+baz:"peanut butter"+bar  '  => { foo => undef, bar => undef, baz => 'peanut butter' } ],
  [ 'foo baz:"peanut\"butter" bar  ' => { foo => undef, bar => undef, baz => 'peanut"butter' } ],
  [ '"peanut butter":chunky salty  ' => { q{peanut butter} => 'chunky', salty => undef } ],

  [ 'foo baz:"peanut butter\" bar  '  => undef ],

  [ q{"foo\\"bar\\\\"} => { 'foo\\"bar\\\\' => undef } ],
);

for (@tagstrings) {
  my ($string, $expected_tags) = @$_;

  my $tags = eval { String::TagString->tags_from_string($string); };

  is_deeply(
    $tags,
    $expected_tags,
    "tags from <$string>" . (! defined $expected_tags ? ' (invalid)' : ''),
  ) or diag explain $tags;
}

my @tags = (
  [ { }                                             => ''                   ],
  [ { foo => undef }                                => 'foo'                ],
  [ { foo => undef, bar => undef }                  => 'bar foo'            ],
  [ { foo => undef, bar => undef, baz => undef    } => 'bar baz foo'        ],
  [ { foo => undef, bar => undef, baz => ''       } => 'bar baz: foo'       ],
  [ { foo => undef, bar => undef, baz => 'peanut' } => 'bar baz:peanut foo' ],
  [ { foo => undef, bar => "peanut butter"        } => 'bar:"peanut butter" foo' ],

  [ { 'peanut"butter' => 'chunky' } => '"peanut\"butter":chunky' ],
);

for (@tags) {
  my ($tags, $expected_string) = @$_;

  my $string = eval { String::TagString->string_from_tags($tags); };

  is_deeply(
    $string,
    $expected_string,
    "string <$expected_string> from tags",
  );
}
