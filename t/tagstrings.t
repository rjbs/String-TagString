#!perl -T

use strict;
use warnings;

use Test::More 'no_plan';
use Text::TagString;

my @tagstrings = (
  [ ''                   => {} ],
  [ 'foo'                => { foo => undef } ],
  [ 'foo bar'            => { foo => undef, bar => undef } ],
  [ 'foo baz:peanut bar' => { foo => undef, bar => undef, baz => 'peanut' } ],
  [ 'foo baz: bar'       => { foo => undef, bar => undef, baz => ''       } ],
  [ 'bad()tag foo bar'   => undef ],
  [ 'bad:tag|value foo'  => undef ],
);

for (@tagstrings) {
  my ($string, $expected_tags) = @$_;

  my $tags = eval { Text::TagString->tags_from_string($string); };

  is_deeply(
    $tags,
    $expected_tags,
    "tags from <$string>" . (! defined $expected_tags ? ' (invalid)' : ''),
  );
}

my @tags = (
  [ { }                                             => ''                   ],
  [ { foo => undef }                                => 'foo'                ],
  [ { foo => undef, bar => undef }                  => 'bar foo'            ],
  [ { foo => undef, bar => undef, baz => undef    } => 'bar baz foo'        ],
  [ { foo => undef, bar => undef, baz => ''       } => 'bar baz: foo'       ],
  [ { foo => undef, bar => undef, baz => 'peanut' } => 'bar baz:peanut foo' ],
);

for (@tags) {
  my ($tags, $expected_string) = @$_;

  my $string = eval { Text::TagString->string_from_tags($tags); };

  is_deeply(
    $string,
    $expected_string,
    "string <$expected_string> from tags",
  );
}
