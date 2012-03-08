# Do not edit this file - Generated by Perlito5 8.0
use v5;
use utf8;
use strict;
use warnings;
no warnings ('redefine', 'once', 'void', 'uninitialized', 'misc', 'recursion');
use Perlito5::Perl5::Runtime;
our $MATCH = Perlito5::Match->new();
package main;
package Perlito5::Grammar::Bareword;
use Perlito5::Precedence;
use Perlito5::Grammar;
sub Perlito5::Grammar::Bareword::term_bareword {
    ((my  $self) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $p) = $pos);
    ((my  $m_namespace) = Perlito5::Grammar->optional_namespace_before_ident($str, $p));
    ($p = $m_namespace->{'to'});
    ((my  $m_name) = Perlito5::Grammar->ident($str, $p));
    if ($m_name->{'bool'}) {

    }
    else {
        return ($m_name)
    };
    ($p = $m_name->{'to'});
    ((my  $name) = $m_name->flat());
    ((my  $namespace) = $m_namespace->flat());
    ((my  $full_name) = $name);
    if ($namespace) {
        ($full_name = ($namespace . '::' . $name))
    };
    (my  $has_space_after);
    ((my  $m) = Perlito5::Grammar->ws($str, $p));
    if (($m->{'bool'})) {
        ($has_space_after = 1);
        ($p = $m->{'to'})
    };
    if (((substr($str, $p, 2) eq '=>'))) {
        ($m_name->{'capture'} = ['term', Perlito5::AST::Val::Buf->new(('buf' => $full_name))]);
        ($m_name->{'to'} = $p);
        return ($m_name)
    };
    if (((substr($str, $p, 2) eq '->'))) {
        ($m_name->{'capture'} = ['term', Perlito5::AST::Proto->new(('name' => $full_name))]);
        ($m_name->{'to'} = $p);
        return ($m_name)
    };
    if (($has_space_after)) {
        ((my  $m_list) = Perlito5::Expression->list_parse($str, $p));
        if (($m_list->{'bool'})) {
            ($m_name->{'capture'} = ['postfix_or_term', 'funcall', $namespace, $name, $m_list->flat()]);
            ($m_name->{'to'} = $m_list->{'to'});
            return ($m_name)
        }
    };
    ($m_name->{'capture'} = ['postfix_or_term', 'funcall_no_params', $namespace, $name]);
    return ($m_name)
};
1;

1;
