package Perlito5;

$VERSION = '9.014';

1;

=pod

=head1 NAME

Perlito5 - a Perl5 compiler

=head1 SYNOPSIS

    use Perlito5::Compiler;
    use Perlito5::Javascript2::Emitter;
    use Perlito5::Javascript2::Runtime;

    my $perl5_source = ' print "hello, World!\n" ';
    $Perlito5::PKG_NAME = 'main';
    $Perlito5::PROTO    = {};
    my $ast = Perlito5::Grammar::exp_stmts($perl5_source, 0);
    print Dumper $ast;
    my $js_source = Perlito5::AST::CompUnit::emit_javascript2_program([
        Perlito5::AST::CompUnit->new( name => 'main', body => Perlito5::Match::flat($ast) )
    ]);
    print $js_source;


    # in the command line:

    perlito5 --help

    perlito5 -Cjs program.pl

=head1 DESCRIPTION

This program reads Perl5 source code and generates native code.

The compiler options are available with the command:

    perlito5 -h

=head1 COOKBOOK

=head2 Obtaining a "perlito5.js" script that executes in the "node.js" Javascript compiler

    # Step 1: use perlito5 to compile perlito5 to Javascript.
    perlito5 --bootstrapping -Cjs `which perlito5` > perlito5.js

    # Step 2: ensure that PERL5LIB points to the directory where Perlito5.pm is installed.
    echo $PERL5LIB

    # Step 3: set PERL5LIB if needed.
    perldoc -l Perlito5
       # /usr/local/lib/perl5/site_perl/5.20.1/Perlito5.pm
    export PERL5LIB=/usr/local/lib/perl5/site_perl/5.20.1

    # Step 4: install nodejs if needed.

    # Step 5: this should work now:
    nodejs perlito5.js -e ' print "hello, World!\n" '
        # hello, World!


=head2 Obtaining a Perl compiler script that runs in the browser

    # Step 1: create a Perl script that implements C<compile_p5_to_js()>.
    #         Save this to "perlito5-browser.pl":

    use strict;
    use warnings;
    use Perlito5::Compiler;
    use Perlito5::Javascript2::Emitter;
    use Perlito5::Javascript2::Runtime;
    sub compile_p5_to_js {
        my $s = shift;
        $Perlito5::PKG_NAME = 'main';
        $Perlito5::PROTO    = {};
        my $ast = Perlito5::Grammar::exp_stmts($s, 0);
        Perlito5::AST::CompUnit::emit_javascript2_program(
            [ Perlito5::AST::CompUnit->new( name => 'main', body => Perlito5::Match::flat($ast) ) ]
        );
    }

    # Step 2: use perlito5 to compile your "perlito5-browser.pl" script to Javascript.

    perlito5 --bootstrapping -Cjs perlito5-browser.pl > perlito5-browser.js

    # Step 3: load the compiler in the browser;
    #         compile perl5 to javascript;
    #         eval() the javascript code.
    # Note: the default implementation for "print" will invoke console.log();
    #       you can override this by redefining p5pkg['Perlito5::IO'].print()

    <html>
      <head>
        <script type="text/javascript" src="perlito5-browser.js"></script>
        <script type="text/javascript">
            function perl_exec(source) {
                var js_source = p5pkg.main.compile_p5_to_js([source]);
                eval(js_source);
            }
            function hello() {
                perl_exec(' print "hello, World!\n" ');
            }
        </script>
      </head>
      <body>
        <input type="button" value="Execute" onclick="hello()"/>
      </body>
    </html>


=head1 AUTHORS

Flavio Soibelmann Glock <fglock@gmail.com>.

=head1 SEE ALSO

L<http://fglock.github.io/Perlito>

=head1 COPYRIGHT

Copyright 2011, 2012, 2015 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/artistic.html>

=cut

