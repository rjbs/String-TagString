package Text::TagString;

use warnings;
use strict;

=head1 NAME

Text::TagString - turn strings into tags and tags into strings

=head1 VERSION

version 0.01

 $Id$

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use Text::TagString;

  my $tags = Text::TagString->tags_from_string($string);

  # or

  my $string = Text::TagString->string_from_tags($tags);

=head1 DESCRIPTION

Quick summary of what the module does.

=head1 METHODS

=cut

sub valid_tag {
  my ($class, $tag) = @_;

  return ($tag =~ /\A[@\pL\d_:.*][-\pL\d_:.*]*\z/) ? 1 : ();
}

sub valid_tag_value {
  my ($class, $value) = @_;

  return ($value =~ /\A[-\pL\d:_.*]*\z/) ? 1 : ();
}

=head2 tag_from_string

=cut

sub tag_from_string {
  my ($class, $string) = @_;
  my ($tag, $value) = split /:/, $_, 2;

  Carp::carp "empty tag" unless $tag;

  Carp::carp "invalid tag <$tag>" if ! $class->valid_tag($tag);

  Carp::carp "invalid tag value <$value>" if ! $class->valid_tag_value($value);

  return ($tag, $value);
}

=head2 tags_from_string

=cut

sub tags_from_string {
  my ($class, $tagstring) = @_;

  return {} unless $tagstring and $tagstring =~ /\S/;

  # remove leading and trailing spaces
  $tagstring =~ s/\A\s*//;

  my %tags = map { (index($_, ':') > 0) ? split(/:/, $_, 2) : ($_ => undef) }
                 split /(?:\+|\s)+/, $tagstring;

  die "invalid characters in tagstring"
    if grep { defined $_ and $_ !~ /\A[@\pL\d_:.*][-\pL\d_:.*]*\z/ } keys %tags;
  die "invalid characters in tagstring"
    if grep { defined $_ and $_ !~ /\A[-\pL\d:_.*]*\z/ } values %tags;

  return \%tags;
}

=head2 string_from_tags

=cut

sub string_from_tags {
  my ($class, $tags) = @_;

  return "" unless defined $tags;

  Carp::carp "tagstring must be a hash or array reference"
    unless (ref $tags) and ((ref $tags eq 'HASH') or (ref $tags eq 'ARRAY'));

  $tags = { map { $_ => undef } @$tags } if ref $tags eq 'ARRAY';

  my $tagstring
    = join q{ },
      map { "$_" . (defined $tags->{$_} ? ":$tags->{$_}" : '') }
      sort keys %$tags;

  return $tagstring;
}


=head1 AUTHOR

Ricardo Signes, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-text-tagstring@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2006 Ricardo Signes, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
