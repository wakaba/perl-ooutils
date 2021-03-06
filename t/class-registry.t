package test::Class::Registry;
use strict;
use warnings;
use base qw(Test::Class);
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::More;
use Class::Registry;

{
    package test::class::registry::test1;
    $INC{'test/class/registry/test1.pm'} = 1;
}

{
    package test::class::registry::test2;
    $INC{'test/class/registry/test2.pm'} = 1;
}

sub _default : Test(5) {
    Class::Registry->default(deftest => 'test::class::registry::default');
    is +Class::Registry->get('deftest'), 'test::class::registry::default';

    my @keys = Class::Registry->keys;
    ok grep { $_ eq 'deftest' } @keys;

    Class::Registry->set(deftest => 'test::class::registry::test2');
    is +Class::Registry->get('deftest'), 'test::class::registry::test2';

    @keys = Class::Registry->keys;
    ok grep { $_ eq 'deftest' } @keys;
    
    Class::Registry->default(deftest => 'test::class::registry::default2');
    is +Class::Registry->get('deftest'), 'test::class::registry::test2';
}

sub _getset : Test(3) {
    Class::Registry->set(test1 => 'test::class::registry::test1');
    is +Class::Registry->get('test1'), 'test::class::registry::test1';

    Class::Registry->set(test1 => 'test::class::registry::test2');
    is +Class::Registry->get('test1'), 'test::class::registry::test2';

    Class::Registry->set(test2 => 'test::class::registry::test2');
    is +Class::Registry->get('test2'), 'test::class::registry::test2';
}

sub _require_found : Test(2) {
    Class::Registry->set(test1 => 'test::class::registry::test1');

    is +Class::Registry->require('test1'), 'test::class::registry::test1';
    is +Class::Registry->require('test1'), 'test::class::registry::test1';
}

sub _require_not_found_1 : Test(1) {
    Class::Registry->set(test1 => 'test::class::registry::not_found');
    eval {
        Class::Registry->require('test1');
        ok 0;
    } or do {
        ok 1;
    };
}

sub _require_not_found_2 : Test(1) {
    eval {
        Class::Registry->require('test_not_found');
        ok 0;
    } or do {
        ok 1;
    };
}

sub _load_not_found : Test(1) {
    eval {
        Class::Registry->load('test::Class::Not::Found');
        ok 0;
    } or do {
        ok $@;
    };
}

sub _load_require_as_is : Test(1) {
    {
        package test::Class::Registry::load::1;
        $INC{'test/Class/Registry/load/1.pm'} = 1;
        sub hoge { 123 }
    }
    is +Class::Registry->load('test::Class::Registry::load::1')->hoge, 123;
}

sub _load_require_class_specified : Test(1) {
    {
        package test::Class::Registry::load::2::fuga;
        $INC{'test/Class/Registry/load/2/fuga.pm'} = 1;
        sub hoge { 521 }
    }
    Class::Registry->set('test::Class::Registry::load::2' => 'test::Class::Registry::load::2::fuga');
    is +Class::Registry->load('test::Class::Registry::load::2')->hoge, 521;
}

__PACKAGE__->runtests;

1;
