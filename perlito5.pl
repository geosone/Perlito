# Do not edit this file - Generated by Perlito5 8.0
use v5;
use utf8;
use strict;
use warnings;
no warnings ('redefine', 'once', 'void', 'uninitialized', 'misc', 'recursion');
use Perlito5::Perl5::Runtime;
our $MATCH = Perlito5::Match->new();
package main;
use v5;
package Perlito;
use Perlito5::Match;
use Perlito5::Emitter::Token;
use Perlito5::Expression;
use Perlito5::Grammar::Control;
use Perlito5::Grammar::Regex;
use Perlito5::Grammar;
use Perlito5::Javascript::Emitter;
use Perlito5::Macro;
use Perlito5::Perl5::Emitter;
use Perlito5::Perl6::Emitter;
use Perlito5::Precedence;
use Perlito5::Runtime;
((my  $_V6_COMPILER_NAME) = 'Perlito5');
((my  $_V6_COMPILER_VERSION) = '8.0');
((my  $source) = '');
((my  $backend) = '');
((my  $execute) = 0);
((my  $verbose) = 0);
((my  $comp_units) = []);
((my  $perl5lib) = '.' . chr(47) . 'src5' . chr(47) . 'lib');
((my  $expand_use) = 1);
if (($verbose)) {
    warn((chr(47) . chr(47) . ' Perlito5 compiler'));
    warn((chr(47) . chr(47) . ' ARGV: ' . join(' ', @ARGV)))
};
(my  %module_seen);
sub modulename_to_filename {
    ((my  $s) = shift());
    return (Perlito5::Runtime::_replace($s, '::', chr(47)))
};
sub expand_use {
    ((my  $stmt) = shift());
    ((my  $module_name) = $stmt->mod());
    if (((($module_name eq 'v5') || ($module_name eq 'strict')) || ($module_name eq 'feature'))) {
        return ()
    };
    if ((!(($module_seen{$module_name})))) {
        ($module_seen{$module_name} = 1);
        if (((($backend eq 'perl5')) || (($backend eq 'ast-perl5')))) {

        }
        else {
            ((my  $filename) = $module_name);
            ($filename = ($perl5lib . chr(47) . modulename_to_filename($filename) . '.pm'));
            if (($verbose)) {
                warn((chr(47) . chr(47) . ' now loading: '), $filename)
            };
            ((my  $source) = IO::slurp($filename));
            ((my  $m) = Perlito5::Grammar->exp_stmts($source, 0));
            add_comp_unit([CompUnit->new(('name' => 'main'), ('body' => $m->flat()))])
        }
    }
};
sub add_comp_unit {
    ((my  $parse) = shift());
    for my $comp_unit (@{$parse}) {
        if ((($expand_use && $comp_unit->isa('Use')))) {
            expand_use($comp_unit)
        }
        else {
            if (($comp_unit->isa('CompUnit'))) {
                if (($verbose)) {
                    warn(('parsed comp_unit: ' . chr(39)), $comp_unit->name(), (chr(39)))
                };
                for my $stmt (@{$comp_unit->body()}) {
                    if ((($expand_use && $stmt->isa('Use')))) {
                        expand_use($stmt)
                    }
                }
            }
        };
        push(@{$comp_units}, $comp_unit )
    }
};
if (((($ARGV[0] eq '-v')) || (($ARGV[0] eq '--verbose')))) {
    ($verbose = 1);
    shift(@ARGV)
};
if (((substr($ARGV[0], 0, 2) eq '-C'))) {
    ($backend = substr($ARGV[0], 2, 10));
    ($execute = 0);
    shift(@ARGV);
    if (((((($backend eq 'perl5')) || (($backend eq 'python'))) || (($backend eq 'ruby'))) || ($backend eq 'perl6'))) {
        ($expand_use = 0)
    }
};
if (((substr($ARGV[0], 0, 2) eq '-B'))) {
    ($backend = substr($ARGV[0], 2, 10));
    ($execute = 1);
    shift(@ARGV);
    if ((((($backend eq 'perl5')) || (($backend eq 'python'))) || (($backend eq 'ruby')))) {
        ($expand_use = 0)
    }
};
if (((($ARGV[0] eq '-V')) || (($ARGV[0] eq '--version')))) {
    ($backend = '');
    Perlito5::Runtime::say($_V6_COMPILER_NAME, (' '), $_V6_COMPILER_VERSION);
    shift(@ARGV)
}
else {
    if ((((($ARGV[0] eq '-h')) || (($ARGV[0] eq '--help'))) || (($backend eq '')))) {
        ($backend = '');
        Perlito5::Runtime::say($_V6_COMPILER_NAME, (' '), $_V6_COMPILER_VERSION, (chr(10) . 'perlito5 [switches] [programfile]' . chr(10) . '  switches:' . chr(10) . '    -h --help' . chr(10) . '    -v --verbose' . chr(10) . '    -V --version' . chr(10) . '    -Ctarget        target backend: js, perl5, perl6, ast-perl5' . chr(10) . '    --expand_use --noexpand_use' . chr(10) . '                    expand ' . chr(39) . 'use' . chr(39) . ' statements at compile time' . chr(10) . '    -e program      one line of program (omit programfile)' . chr(10)));
        shift(@ARGV)
    }
};
if ((($ARGV[0] eq '--expand_use'))) {
    ($expand_use = 1);
    shift(@ARGV)
};
if ((($ARGV[0] eq '--noexpand_use'))) {
    ($expand_use = 0);
    shift(@ARGV)
};
if ((($backend && @ARGV))) {
    if ((($ARGV[0] eq '-e'))) {
        shift(@ARGV);
        if (($verbose)) {
            warn((chr(47) . chr(47) . ' source from command line: '), $ARGV[0])
        };
        ($source = shift(@ARGV))
    }
    else {
        if (($verbose)) {
            warn((chr(47) . chr(47) . ' source from file: '), $ARGV[0])
        };
        ($source = IO::slurp(shift(@ARGV)))
    };
    if (($verbose)) {
        warn((chr(47) . chr(47) . ' backend: '), $backend);
        warn(('now parsing'))
    };
    ((my  $m) = Perlito5::Grammar->exp_stmts($source, 0));
    add_comp_unit($m->flat());
    ($comp_units = [CompUnit->new(('name' => 'main'), ('body' => $comp_units))]);
    if ((($backend eq 'ast-perl5'))) {
        Perlito5::Runtime::say((chr(35) . ' AST dump - do not edit this file - Generated by '), $_V6_COMPILER_NAME, (' '), $_V6_COMPILER_VERSION);
        Perlito5::Runtime::say(($comp_units))
    };
    if ((($backend eq 'perl5'))) {
        Perlito5::Runtime::say((chr(35) . ' Do not edit this file - Generated by '), $_V6_COMPILER_NAME, (' '), $_V6_COMPILER_VERSION);
        print(CompUnit::emit_perl5_program($comp_units))
    };
    if ((($backend eq 'perl6'))) {
        Perlito5::Runtime::say((chr(35) . ' Do not edit this file - Generated by '), $_V6_COMPILER_NAME, (' '), $_V6_COMPILER_VERSION);
        print(CompUnit::emit_perl6_program($comp_units))
    };
    if ((($backend eq 'js'))) {
        Perlito5::Runtime::say((chr(47) . chr(47) . ' Do not edit this file - Generated by '), $_V6_COMPILER_NAME, (' '), $_V6_COMPILER_VERSION);
        ((my  $filename) = ($perl5lib . chr(47) . 'Perlito5' . chr(47) . 'Javascript' . chr(47) . 'Runtime.js'));
        if (($verbose)) {
            warn((chr(47) . chr(47) . ' now loading: '), $filename)
        };
        ((my  $source) = IO::slurp($filename));
        Perlito5::Runtime::say($source);
        ((my  $filename) = ($perl5lib . chr(47) . 'Perlito5' . chr(47) . 'Javascript' . chr(47) . 'CORE.js'));
        if (($verbose)) {
            warn((chr(47) . chr(47) . ' now loading: '), $filename)
        };
        ((my  $source) = IO::slurp($filename));
        Perlito5::Runtime::say($source);
        print(CompUnit::emit_javascript_program($comp_units))
    };
    if ((($backend eq 'java'))) {
        Perlito5::Runtime::say((chr(47) . chr(47) . ' Do not edit this file - Generated by '), $_V6_COMPILER_NAME, (' '), $_V6_COMPILER_VERSION);
        print(CompUnit::emit_java_program($comp_units))
    }
};

1;
