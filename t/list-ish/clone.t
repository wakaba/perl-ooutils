package test::List::Ish::clone;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;
use Test::More;
use base qw(Test::Class);
use List::Ish;
use JSON::XS;

# ------ slice ------

sub _slice_all : Test(6) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  my $l2 = $l1->slice (0, 2);
  isa_ok $l2, 'List::Ish';
  isnt $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
  is $l2->[2], 3;
  is $l2->length, 3;
} # _slice_all

sub _slice_too_many : Test(6) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  my $l2 = $l1->slice (0, 5);
  isa_ok $l2, 'List::Ish';
  isnt $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
  is $l2->[2], 3;
  is $l2->length, 3;
} # _slice_too_many

sub _slice_no_args : Test(6) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  my $l2 = $l1->slice;
  isa_ok $l2, 'List::Ish';
  isnt $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
  is $l2->[2], 3;
  is $l2->length, 3;
} # _slice_no_args

# ------ clone ------

sub _clone : Test(3) {
  my $l1 = List::Ish->new ([1, 5, undef]);
  my $l2 = $l1->clone;
  isa_ok $l2, 'List::Ish';
  is_deeply $l2, $l1;
  isnt $l2, $l1;
} # _clone

sub _clone_empty : Test(3) {
  my $l1 = List::Ish->new;
  my $l2 = $l1->clone;
  isa_ok $l2, 'List::Ish';
  is_deeply $l2, $l1;
  isnt $l2, $l1;
} # _clone_empty

sub _clone_subclass : Test(2) {
  local @My::List::Ish::Subclass::Clone::ISA = qw(List::Ish);
  my $l1 = My::List::Ish::Subclass::Clone->new([1, 4, 10]);
  my $l2 = $l1->clone;
  isa_ok $l2, 'My::List::Ish::Subclass::Clone';
  is_deeply $l2, $l1;
} # _clone_subclass

# ------ dup ------

sub _dup : Test(3) {
  my $l1 = List::Ish->new ([1, 5, undef]);
  my $l2 = $l1->dup;
  isa_ok $l2, 'List::Ish';
  is_deeply $l2, $l1;
  isnt $l2, $l1;
} # _dup

sub _dup_empty : Test(3) {
  my $l1 = List::Ish->new;
  my $l2 = $l1->dup;
  isa_ok $l2, 'List::Ish';
  is_deeply $l2, $l1;
  isnt $l2, $l1;
} # _dup_empty

sub _dup_subclass : Test(2) {
  local @My::List::Ish::Subclass::Dup::ISA = qw(List::Ish);
  my $l1 = My::List::Ish::Subclass::Dup->new([1, 4, 10]);
  my $l2 = $l1->dup;
  isa_ok $l2, 'My::List::Ish::Subclass::Dup';
  is_deeply $l2, $l1;
} # _dup_subclass

# ------ to_list ------

sub _to_list : Test(1) {
  my $l = List::Ish->new ([1, 2, undef, 3]);
  my @l = $l->to_list;
  is_deeply \@l, [1, 2, undef, 3];
} # _to_list

sub _to_list_2 : Test(1) {
  my $l = List::Ish->new ([undef]);
  my @l = $l->to_list;
  is_deeply \@l, [undef];
} # _to_list_2

sub _to_list_empty : Test(1) {
  my $l = List::Ish->new ([]);
  my @l = $l->to_list;
  is_deeply \@l, [];
} # _to_list_empty

sub _as_list : Test(1) {
    my $l = List::Ish->new;
    is $l->as_list, $l;
}

# ------ TO_JSON ------

sub _to_json : Test(1) {
  my $l = List::Ish->new (['abc', 123]);
  is +JSON::XS->new->convert_blessed->encode ($l), '["abc",123]';
} # _to_json

# ------ as_hashref ------

sub _as_hashref : Test(2) {
  my $l = List::Ish->new (['abc', 124]);
  is_deeply $l->as_hashref, {abc => 1, 124 => 1};
} # _as_hashref

sub _as_hashref_2 : Test(4) {
  my $l = List::Ish->new ([0, List::Ish->new]);
  is ref $l->as_hashref, 'HASH';
  ok $l->as_hashref->{0};
  ok grep { /List::Ish/ } keys %{$l->as_hashref};
  isnt $l->as_hashref, $l->as_hashref;
} # _as_hashref_2

# ------ as_hashref_by_key ------

sub _as_hashref_by_key : Test(1) {
  my $l = List::Ish->new ([10, 20]);
  is_deeply $l->as_hashref_by_key (sub { $_ * 2 }), {20 => 10, 40 => 20};
} # _as_hashref_by_key

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2012 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
