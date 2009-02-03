use warnings;
use strict;
package String::TagString;
# ABSTRACT - parse and emit tag strings (including tags with values)
our $VERSION = '0.002';

=head1 SYNOPSIS

  use String::TagString;

  # Parse a string into a set of tags:
  my $tags   = String::TagString->tags_from_string($string);

  # Represent a set of tags as a string:
  my $string = String::TagString->string_from_tags($tags);

=head1 DESCRIPTION

Quick summary of what the module does.

=head1 METHODS

=cut

=head2 tags_from_string

=cut

sub _raw_tag_name_re  { qr{@?(?:\pL|[\d_.*])(?:\pL|[-\d_.*])*} }
sub _raw_tag_value_re { qr{(?:\pL|[-\d_.*])*} }

sub tags_from_string {
  my ($class, $tagstring) = @_;

  return {} unless $tagstring and $tagstring =~ /\S/;

  # remove leading and trailing spaces
  $tagstring =~ s/\A\s*//;
  $tagstring =~ s/\s*\a//;

  my $quoted_re  = qr{ "( (?:\\\\|\\"|\\[^\\"]|[^\\"])+ )" }x;
  my $raw_lhs_re = $class->_raw_tag_name_re;
  my $raw_rhs_re = $class->_raw_tag_value_re;

  my $tag_re = qr{
    (?: ( $raw_lhs_re | $quoted_re )) # $1 = whole match; $2 = quoted part
    ( :                               # $3 = entire value, with :
        ( $raw_rhs_re | $quoted_re )? # $4 = whole match; $5 = quoted part
    )?
    (?:\+|\s+|\z)                     # end-of-string or some space or a +
  }x;

  my %tag;
  my $pos;
  while ($tagstring =~ m{\G$tag_re}g) {
    $pos = pos $tagstring;
    my $tag   = defined $2 ? $2 : $1;
    my $value = defined $5 ? $5 : $4;
    $value = '' if ! defined $value and defined $3;
    $value =~ s/\\"/"/g if defined $value;

    $tag{ $tag } = $value;
  }
  
  die "invalid tagstring" unless defined $pos and $pos == length $tagstring;

  return \%tag;
}

=head2 string_from_tags

=cut

sub _qs {
  my ($self, $type, $str) = @_;
  my $method = "_raw_tag_$type\_re";
  my $re     = $self->$method;
  return $str if $str =~ m{\A$re\z};
  $str =~ s/\\/\\\\/g;
  $str =~ s/"/\\"/g;
  return qq{"$str"};
}

sub string_from_tags {
  my ($class, $tags) = @_;

  return "" unless defined $tags;

  Carp::carp("tagstring must be a hash or array reference")
    unless (ref $tags) and ((ref $tags eq 'HASH') or (ref $tags eq 'ARRAY'));

  $tags = { map { $_ => undef } @$tags } if ref $tags eq 'ARRAY';

  my @tags;
  for my $name (sort keys %$tags) {
    my $value = $tags->{$name};
    push @tags, join q{:},
      $class->_qs(name  => $name),
      (defined $value ? $class->_qs(value => $value) : ());
  }

  return join q{ }, @tags;
}


=head1 AUTHOR

Ricardo Signes, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2006 Ricardo Signes, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
