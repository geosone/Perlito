# Do not edit this file - Generated by Perlito 6.0
use v5;
use utf8;
use strict;
use warnings;
no warnings ('redefine', 'once', 'void', 'uninitialized', 'misc', 'recursion');
use Perlito::Perl5::Runtime;
use Perlito::Perl5::Prelude;
our $MATCH = Perlito::Match->new();
{
package GLOBAL;
sub new { shift; bless { @_ }, "GLOBAL" }

# use v6 
;
{
package Perl5;
sub new { shift; bless { @_ }, "Perl5" }
sub to_bool { my $cond = $_[0]; if (Main::bool((((Main::isa($cond, 'Val::Num') || Main::isa($cond, 'Val::Buf')) || Main::isa($cond, 'Val::Int')) || ((Main::isa($cond, 'Apply') && ((((($cond->code() eq 'bool')) || (($cond->code() eq 'True'))) || (($cond->code() eq 'False'))))))))) { return($cond) } ; return(Apply->new(('code' => 'bool'), ('arguments' => do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, $cond ); $List_a }))) }
}

;
{
package CompUnit;
sub new { shift; bless { @_ }, "CompUnit" }
sub name { $_[0]->{name} };
sub body { $_[0]->{body} };
sub emit_perl5 { my $self = $_[0]; (my  $List_body = []); for ( @{$self->{body} || []} ) { if (Main::bool(defined($_))) { push( @{$List_body}, $_ ) }  }; '{' . '
' . 'package ' . $self->{name} . ';' . '
' . 'sub new { shift; bless { @_ }, "' . $self->{name} . '" }' . '
' . Main::join(([ map { $_->emit_perl5() } @{ $List_body } ]), ';' . '
') . '
' . '}' . '
' . '
' };
sub emit_perl5_program { my $comp_units = $_[0]; ((my  $str = undef) = '' . 'use v5;' . '
' . 'use utf8;' . '
' . 'use strict;' . '
' . 'use warnings;' . '
' . 'no warnings (\'redefine\', \'once\', \'void\', \'uninitialized\', \'misc\', \'recursion\');' . '
' . 'use Perlito::Perl5::Runtime;' . '
' . 'use Perlito::Perl5::Prelude;' . '
' . 'our ' . '$' . 'MATCH = Perlito::Match->new();' . '
'); for my $comp_unit ( @{(($comp_units) || []) || []} ) { ($str = $str . $comp_unit->emit_perl5()) }; ($str = $str . '1;' . '
'); return($str) }
}

;
{
package Val::Int;
sub new { shift; bless { @_ }, "Val::Int" }
sub int { $_[0]->{int} };
sub emit_perl5 { my $self = $_[0]; $self->{int} }
}

;
{
package Val::Bit;
sub new { shift; bless { @_ }, "Val::Bit" }
sub bit { $_[0]->{bit} };
sub emit_perl5 { my $self = $_[0]; $self->{bit} }
}

;
{
package Val::Num;
sub new { shift; bless { @_ }, "Val::Num" }
sub num { $_[0]->{num} };
sub emit_perl5 { my $self = $_[0]; $self->{num} }
}

;
{
package Val::Buf;
sub new { shift; bless { @_ }, "Val::Buf" }
sub buf { $_[0]->{buf} };
sub emit_perl5 { my $self = $_[0]; '\'' . Main::perl_escape_string($self->{buf}) . '\'' }
}

;
{
package Lit::Block;
sub new { shift; bless { @_ }, "Lit::Block" }
sub sig { $_[0]->{sig} };
sub stmts { $_[0]->{stmts} };
sub emit_perl5 { my $self = $_[0]; (my  $List_body = []); for ( @{$self->{stmts} || []} ) { if (Main::bool(defined($_))) { push( @{$List_body}, $_ ) }  }; Main::join(([ map { $_->emit_perl5() } @{ $List_body } ]), '; ') }
}

;
{
package Lit::Array;
sub new { shift; bless { @_ }, "Lit::Array" }
sub array1 { $_[0]->{array1} };
sub emit_perl5 { my $self = $_[0]; ((my  $ast = undef) = $self->expand_interpolation()); return($ast->emit_perl5()) }
}

;
{
package Lit::Hash;
sub new { shift; bless { @_ }, "Lit::Hash" }
sub hash1 { $_[0]->{hash1} };
sub emit_perl5 { my $self = $_[0]; ((my  $ast = undef) = $self->expand_interpolation()); return($ast->emit_perl5()) }
}

;
{
package Index;
sub new { shift; bless { @_ }, "Index" }
sub obj { $_[0]->{obj} };
sub index_exp { $_[0]->{index_exp} };
sub emit_perl5 { my $self = $_[0]; $self->{obj}->emit_perl5() . '->[' . $self->{index_exp}->emit_perl5() . ']' }
}

;
{
package Lookup;
sub new { shift; bless { @_ }, "Lookup" }
sub obj { $_[0]->{obj} };
sub index_exp { $_[0]->{index_exp} };
sub emit_perl5 { my $self = $_[0]; $self->{obj}->emit_perl5() . '->{' . $self->{index_exp}->emit_perl5() . '}' }
}

;
{
package Var;
sub new { shift; bless { @_ }, "Var" }
sub sigil { $_[0]->{sigil} };
sub twigil { $_[0]->{twigil} };
sub namespace { $_[0]->{namespace} };
sub name { $_[0]->{name} };
sub emit_perl5 { my $self = $_[0]; ((my  $table = undef) = do { (my  $Hash_a = {}); ($Hash_a->{'$'} = '$'); ($Hash_a->{'@'} = '$List_'); ($Hash_a->{'%'} = '$Hash_'); ($Hash_a->{'&'} = '$Code_'); $Hash_a }); ((my  $ns = undef) = ''); if (Main::bool($self->{namespace})) { ($ns = $self->{namespace} . '::') } else { if (Main::bool((((($self->{sigil} eq '@')) && (($self->{twigil} eq '*'))) && (($self->{name} eq 'ARGS'))))) { return('(\\@ARGV)') } ; if (Main::bool(($self->{twigil} eq '.'))) { return('$self->{' . $self->{name} . '}') } ; if (Main::bool(($self->{name} eq '/'))) { return($table->{$self->{sigil}} . 'MATCH') }  }; return($table->{$self->{sigil}} . $ns . $self->{name}) };
sub plain_name { my $self = $_[0]; if (Main::bool($self->{namespace})) { return($self->{namespace} . '::' . $self->{name}) } ; return($self->{name}) }
}

;
{
package Proto;
sub new { shift; bless { @_ }, "Proto" }
sub name { $_[0]->{name} };
sub emit_perl5 { my $self = $_[0]; ("" . $self->{name}) }
}

;
{
package Call;
sub new { shift; bless { @_ }, "Call" }
sub invocant { $_[0]->{invocant} };
sub hyper { $_[0]->{hyper} };
sub method { $_[0]->{method} };
sub arguments { $_[0]->{arguments} };
sub emit_perl5 { my $self = $_[0]; ((my  $invocant = undef) = $self->{invocant}->emit_perl5()); if (Main::bool(($invocant eq 'self'))) { ($invocant = '$self') } ; if (Main::bool((($self->{method} eq 'shift')))) { if (Main::bool(($self->{hyper}))) { die('not implemented') } else { return('shift( @{' . $invocant . '} )') } } ; if (Main::bool(((($self->{method} eq 'values')) || (($self->{method} eq 'keys'))))) { if (Main::bool(($self->{hyper}))) { die('not implemented') } else { return('[' . $self->{method} . '( %{' . $invocant . '} )' . ']') } } ; if (Main::bool((((((((($self->{method} eq 'perl')) || (($self->{method} eq 'yaml'))) || (($self->{method} eq 'say'))) || (($self->{method} eq 'join'))) || (($self->{method} eq 'chars'))) || (($self->{method} eq 'isa'))) || (($self->{method} eq 'pairs'))))) { if (Main::bool(($self->{hyper}))) { return('[ map { Main::' . $self->{method} . '( $_, ' . ', ' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')' . ' } @{ ' . $invocant . ' } ]') } else { return('Main::' . $self->{method} . '(' . $invocant . ', ' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')') } } ; if (Main::bool(($self->{method} eq 'push'))) { return('push( @{' . $invocant . '}, ' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ' )') } ; if (Main::bool(($self->{method} eq 'unshift'))) { return('unshift( @{' . $invocant . '}, ' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ' )') } ; if (Main::bool(($self->{method} eq 'pop'))) { return('pop( @{' . $invocant . '} )') } ; if (Main::bool(($self->{method} eq 'shift'))) { return('shift( @{' . $invocant . '} )') } ; if (Main::bool(($self->{method} eq 'elems'))) { return('scalar( @{' . $invocant . '} )') } ; ((my  $meth = undef) = $self->{method}); if (Main::bool(($meth eq 'postcircumfix:<( )>'))) { ($meth = '') } ; ((my  $call = undef) = '->' . $meth . '(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')'); if (Main::bool(($self->{hyper}))) { if (Main::bool(!Main::bool(((Main::isa($self->{invocant}, 'Apply') && ($self->{invocant}->code() eq 'prefix:<@>')))))) { ($invocant = '@{ ' . $invocant . ' }') } ; return('[ map { $_' . $call . ' } ' . $invocant . ' ]') } else { $invocant . $call } }
}

;
{
package Apply;
sub new { shift; bless { @_ }, "Apply" }
sub code { $_[0]->{code} };
sub arguments { $_[0]->{arguments} };
sub namespace { $_[0]->{namespace} };
sub emit_perl5 { my $self = $_[0]; ((my  $ns = undef) = ''); if (Main::bool($self->{namespace})) { ($ns = $self->{namespace} . '::') } ; ((my  $code = undef) = $ns . $self->{code}); if (Main::bool(Main::isa($code, 'Str'))) {  } else { return('(' . $self->{code}->emit_perl5() . ')->(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')') }; if (Main::bool(($code eq 'self'))) { return('$self') } ; if (Main::bool(($code eq 'Mu'))) { return('undef') } ; if (Main::bool(($code eq 'make'))) { return('($MATCH->{capture} = (' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . '))') } ; if (Main::bool(($code eq 'say'))) { return('Main::say(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')') } ; if (Main::bool(($code eq 'print'))) { return('Main::print(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')') } ; if (Main::bool(($code eq 'warn'))) { return('warn(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')') } ; if (Main::bool(($code eq 'array'))) { return('@{' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . '}') } ; if (Main::bool(($code eq 'pop'))) { return('pop( @{' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . '} )') } ; if (Main::bool(($code eq 'push'))) { return('push( @{' . ($self->{arguments}->[0])->emit_perl5() . '}, ' . ($self->{arguments}->[1])->emit_perl5() . ' )') } ; if (Main::bool(($code eq 'shift'))) { return('shift( @{' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . '} )') } ; if (Main::bool(($code eq 'unshift'))) { return('unshift( @{' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . '} )') } ; if (Main::bool(($code eq 'Int'))) { return('(0+' . ($self->{arguments}->[0])->emit_perl5() . ')') } ; if (Main::bool(($code eq 'Num'))) { return('(0+' . ($self->{arguments}->[0])->emit_perl5() . ')') } ; if (Main::bool(($code eq 'bool'))) { return('Main::bool(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')') } ; if (Main::bool(($code eq 'prefix:<~>'))) { return('("" . ' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ')') } ; if (Main::bool(($code eq 'prefix:<!>'))) { return('!Main::bool(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ')') } ; if (Main::bool(($code eq 'prefix:<?>'))) { return('Main::bool(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ')') } ; if (Main::bool(($code eq 'prefix:<$>'))) { return('${' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . '}') } ; if (Main::bool(($code eq 'prefix:<@>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ' || [])') } ; if (Main::bool(($code eq 'prefix:<%>'))) { return('%{' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . '}') } ; if (Main::bool(($code eq 'postfix:<++>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ')++') } ; if (Main::bool(($code eq 'postfix:<-->'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ')--') } ; if (Main::bool(($code eq 'prefix:<++>'))) { return('++(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ')') } ; if (Main::bool(($code eq 'prefix:<-->'))) { return('--(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ') . ')') } ; if (Main::bool(($code eq 'list:<~>'))) { return('' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' . ') . '') } ; if (Main::bool(($code eq 'infix:<+>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' + ') . ')') } ; if (Main::bool(($code eq 'infix:<->'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' - ') . ')') } ; if (Main::bool(($code eq 'infix:<*>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' * ') . ')') } ; if (Main::bool(($code eq 'infix:</>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' / ') . ')') } ; if (Main::bool(($code eq 'infix:<>>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' > ') . ')') } ; if (Main::bool(($code eq 'infix:<<>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' < ') . ')') } ; if (Main::bool(($code eq 'infix:<>=>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' >= ') . ')') } ; if (Main::bool(($code eq 'infix:<<=>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' <= ') . ')') } ; if (Main::bool(($code eq 'infix:<x>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' x ') . ')') } ; if (Main::bool(($code eq 'infix:<&&>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' && ') . ')') } ; if (Main::bool(($code eq 'infix:<||>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' || ') . ')') } ; if (Main::bool(($code eq 'infix:<//>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' // ') . ')') } ; if (Main::bool(($code eq 'infix:<eq>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' eq ') . ')') } ; if (Main::bool(($code eq 'infix:<ne>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ne ') . ')') } ; if (Main::bool(($code eq 'infix:<le>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' le ') . ')') } ; if (Main::bool(($code eq 'infix:<ge>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' ge ') . ')') } ; if (Main::bool(($code eq 'infix:<==>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' == ') . ')') } ; if (Main::bool(($code eq 'infix:<!=>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' != ') . ')') } ; if (Main::bool(($code eq 'infix:<=>>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' => ') . ')') } ; if (Main::bool(($code eq 'infix:<..>'))) { return('[' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ' .. ') . ']') } ; if (Main::bool(($code eq 'ternary:<?? !!>'))) { ((my  $cond = undef) = $self->{arguments}->[0]); if (Main::bool((Main::isa($cond, 'Var') && ($cond->sigil() eq '@')))) { ($cond = Apply->new(('code' => 'prefix:<@>'), ('arguments' => do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, $cond ); $List_a }))) } ; return('(' . Perl5::to_bool($cond)->emit_perl5() . ' ? ' . ($self->{arguments}->[1])->emit_perl5() . ' : ' . ($self->{arguments}->[2])->emit_perl5() . ')') } ; if (Main::bool(($code eq 'circumfix:<( )>'))) { return('(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')') } ; if (Main::bool(($code eq 'infix:<=>'))) { return(emit_perl5_bind($self->{arguments}->[0], $self->{arguments}->[1])) } ; $code . '(' . Main::join(([ map { $_->emit_perl5() } @{ $self->{arguments} } ]), ', ') . ')' };
sub emit_perl5_bind { my $parameters = $_[0]; my $arguments = $_[1]; if (Main::bool(Main::isa($parameters, 'Call'))) { ((my  $a = undef) = $parameters); return('((' . ($a->invocant())->emit_perl5() . ')->{' . $a->method() . '} = ' . $arguments->emit_perl5() . ')') } ; if (Main::bool(Main::isa($parameters, 'Lit::Array'))) { ((my  $a = undef) = $parameters->array1()); ((my  $str = undef) = 'do { '); ((my  $i = undef) = 0); for my $var ( @{($a || []) || []} ) { ($str = $str . ' ' . emit_perl5_bind($var, Index->new(('obj' => $arguments), ('index_exp' => Val::Int->new(('int' => $i))))) . '; '); ($i = ($i + 1)) }; return($str . $parameters->emit_perl5() . ' }') } ; if (Main::bool(Main::isa($parameters, 'Lit::Hash'))) { ((my  $a = undef) = $parameters->hash1()); ((my  $b = undef) = $arguments->hash1()); ((my  $str = undef) = 'do { '); ((my  $i = undef) = 0); (my  $arg = undef); for my $var ( @{($a || []) || []} ) { ($arg = Apply->new(('code' => 'Mu'), ('arguments' => do { (my  $List_a = []); (my  $List_v = []); $List_a }))); for my $var2 ( @{($b || []) || []} ) { if (Main::bool((($var2->[0])->buf() eq ($var->[0])->buf()))) { ($arg = $var2->[1]) }  }; ($str = $str . ' ' . emit_perl5_bind($var->[1], $arg) . '; '); ($i = ($i + 1)) }; return($str . $parameters->emit_perl5() . ' }') } ; if (Main::bool(((Main::isa($parameters, 'Var') && ($parameters->sigil() eq '@')) || (Main::isa($parameters, 'Decl') && ($parameters->var()->sigil() eq '@'))))) { ($arguments = Lit::Array->new(('array1' => do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, $arguments ); $List_a }))) } else { if (Main::bool(((Main::isa($parameters, 'Var') && ($parameters->sigil() eq '%')) || (Main::isa($parameters, 'Decl') && ($parameters->var()->sigil() eq '%'))))) { ($arguments = Lit::Hash->new(('hash1' => do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, $arguments ); $List_a }))) }  }; '(' . $parameters->emit_perl5() . ' = ' . $arguments->emit_perl5() . ')' }
}

;
{
package If;
sub new { shift; bless { @_ }, "If" }
sub cond { $_[0]->{cond} };
sub body { $_[0]->{body} };
sub otherwise { $_[0]->{otherwise} };
sub emit_perl5 { my $self = $_[0]; return('if (' . Perl5::to_bool($self->{cond})->emit_perl5() . ') { ' . (($self->{body})->emit_perl5()) . ' } ' . ((Main::bool($self->{otherwise}) ? ('else { ' . (($self->{otherwise})->emit_perl5()) . ' }') : ''))) }
}

;
{
package While;
sub new { shift; bless { @_ }, "While" }
sub init { $_[0]->{init} };
sub cond { $_[0]->{cond} };
sub continue { $_[0]->{continue} };
sub body { $_[0]->{body} };
sub emit_perl5 { my $self = $_[0]; ((my  $cond = undef) = $self->{cond}); if (Main::bool((Main::isa($cond, 'Var') && ($cond->sigil() eq '@')))) { ($cond = Apply->new(('code' => 'prefix:<@>'), ('arguments' => do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, $cond ); $List_a }))) } ; 'for ( ' . ((Main::bool($self->{init}) ? $self->{init}->emit_perl5() . '; ' : '; ')) . ((Main::bool($cond) ? Perl5::to_bool($cond)->emit_perl5() . '; ' : '; ')) . ((Main::bool($self->{continue}) ? $self->{continue}->emit_perl5() . ' ' : ' ')) . ') { ' . $self->{body}->emit_perl5() . ' }' }
}

;
{
package For;
sub new { shift; bless { @_ }, "For" }
sub cond { $_[0]->{cond} };
sub body { $_[0]->{body} };
sub emit_perl5 { my $self = $_[0]; ((my  $cond = undef) = $self->{cond}); if (Main::bool(!Main::bool(((Main::isa($cond, 'Var') && ($cond->sigil() eq '@')))))) { ($cond = Lit::Array->new(('array1' => do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, $cond ); $List_a }))) } ; (my  $sig = undef); if (Main::bool($self->{body}->sig())) { ($sig = 'my ' . $self->{body}->sig()->emit_perl5() . ' ') } ; return('for ' . $sig . '( @{' . $cond->emit_perl5() . ' || []} ) { ' . $self->{body}->emit_perl5() . ' }') }
}

;
{
package Decl;
sub new { shift; bless { @_ }, "Decl" }
sub decl { $_[0]->{decl} };
sub type { $_[0]->{type} };
sub var { $_[0]->{var} };
sub emit_perl5 { my $self = $_[0]; ((my  $decl = undef) = $self->{decl}); ((my  $name = undef) = $self->{var}->plain_name()); if (Main::bool(($decl eq 'has'))) { return('sub ' . $name . ' { $_[0]->{' . $name . '} }') } ; ((my  $str = undef) = '(' . $self->{decl} . ' ' . $self->{type} . ' ' . $self->{var}->emit_perl5() . ' = '); if (Main::bool((($self->{var})->sigil() eq '%'))) { ($str = $str . '{})') } else { if (Main::bool((($self->{var})->sigil() eq '@'))) { ($str = $str . '[])') } else { ($str = $str . 'undef)') } }; return($str) }
}

;
{
package Sig;
sub new { shift; bless { @_ }, "Sig" }
sub invocant { $_[0]->{invocant} };
sub positional { $_[0]->{positional} };
sub named { $_[0]->{named} };
sub emit_perl5 { my $self = $_[0]; ' print \'Signature - TODO\'; die \'Signature - TODO\'; ' }
}

;
{
package Method;
sub new { shift; bless { @_ }, "Method" }
sub name { $_[0]->{name} };
sub sig { $_[0]->{sig} };
sub block { $_[0]->{block} };
sub emit_perl5 { my $self = $_[0]; ((my  $sig = undef) = $self->{sig}); ((my  $invocant = undef) = $sig->invocant()); ((my  $pos = undef) = $sig->positional()); ((my  $str = undef) = ''); ((my  $i = undef) = 1); for my $field ( @{($pos || []) || []} ) { ($str = $str . 'my ' . $field->emit_perl5() . ' = $_[' . $i . ']; '); ($i = ($i + 1)) }; 'sub ' . $self->{name} . ' { ' . 'my ' . $invocant->emit_perl5() . ' = $_[0]; ' . $str . Main::join(([ map { $_->emit_perl5() } @{ $self->{block} } ]), '; ') . ' }' }
}

;
{
package Sub;
sub new { shift; bless { @_ }, "Sub" }
sub name { $_[0]->{name} };
sub sig { $_[0]->{sig} };
sub block { $_[0]->{block} };
sub emit_perl5 { my $self = $_[0]; ((my  $sig = undef) = $self->{sig}); ((my  $pos = undef) = $sig->positional()); ((my  $str = undef) = ''); ((my  $i = undef) = 0); for my $field ( @{($pos || []) || []} ) { ($str = $str . 'my ' . $field->emit_perl5() . ' = $_[' . $i . ']; '); ($i = ($i + 1)) }; 'sub ' . $self->{name} . ' { ' . $str . Main::join(([ map { $_->emit_perl5() } @{ $self->{block} } ]), '; ') . ' }' }
}

;
{
package Do;
sub new { shift; bless { @_ }, "Do" }
sub block { $_[0]->{block} };
sub emit_perl5 { my $self = $_[0]; 'do { ' . ($self->{block}->emit_perl5()) . ' }' }
}

;
{
package Use;
sub new { shift; bless { @_ }, "Use" }
sub mod { $_[0]->{mod} };
sub emit_perl5 { my $self = $_[0]; if (Main::bool(($self->{mod} eq 'v6'))) { return('
' . '# use ' . $self->{mod} . ' ' . '
') } ; 'use ' . $self->{mod} }
}


}

1;
