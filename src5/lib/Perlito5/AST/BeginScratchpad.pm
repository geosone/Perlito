use v5;
use Perlito5::AST;
use strict;

package Perlito5::AST::CompUnit;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        return __PACKAGE__->new(
            %$self,
            body => [ map { defined($_) && $_->emit_begin_scratchpad() } @{$self->{body}} ],
        );
    }
}

package Perlito5::AST::Int;
{
    sub emit_begin_scratchpad { return $_[0] }
}

package Perlito5::AST::Num;
{
    sub emit_begin_scratchpad { return $_[0] }
}

package Perlito5::AST::Buf;
{
    sub emit_begin_scratchpad { return $_[0] }
}

package Perlito5::AST::Block;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        return __PACKAGE__->new(
            %$self,
            stmts => [ map { defined($_) && $_->emit_begin_scratchpad() } @{$self->{stmts}} ],
            ( $self->{continue}
            ? ( continue => $self->{continue}->emit_begin_scratchpad() )
            : () ),
            # continue => [ map { defined($_) && $_->emit_begin_scratchpad() } @{$self->{continue}} ],
        );
    }
}

package Perlito5::AST::Index;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        return __PACKAGE__->new(
            %$self,
            obj => $self->{obj}->emit_begin_scratchpad(),
            index_exp => $self->{index_exp}->emit_begin_scratchpad(),
        );
    }
}

package Perlito5::AST::Lookup;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        return __PACKAGE__->new(
            %$self,
            obj => $self->{obj}->emit_begin_scratchpad(),
            index_exp => $self->{index_exp}->emit_begin_scratchpad(),
        );
    }
}

package Perlito5::AST::Var;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];

        if (!$self->{namespace} && $Perlito5::BEGIN_SCRATCHPAD{ $self->{_id} || "" }) {
            return __PACKAGE__->new(
                %$self,
                _decl     => "global",
                namespace => "Perlito5::BEGIN",
                name      => "_" . $self->{_id} . "_" . $self->{name},
            );
        }

        return $self;
    }
}

package Perlito5::AST::Call;
{
    sub emit_begin_scratchpad {
        my $self = $_[0]; 
        my $invocant = $self->{invocant}->emit_begin_scratchpad();
        my $arguments;
        if ( $self->{method} eq 'postcircumfix:<[ ]>' ) {
            $arguments = $self->{arguments}->emit_begin_scratchpad();
        }
        elsif ( $self->{method} eq 'postcircumfix:<{ }>' ) {
            $arguments = $self->{arguments}->emit_begin_scratchpad();
        }
        else {
            $arguments = [ map { $_->emit_begin_scratchpad() } @{$self->{arguments}} ];
        }
        my $meth = $self->{method};
        if ( ref($meth) eq 'Perlito5::AST::Var' ) {
            $meth = $meth->emit_begin_scratchpad();
        }
        return __PACKAGE__->new(
            %$self,
            method => $meth,
            invocant => $invocant,
            arguments => $arguments,
        );
    }
}

package Perlito5::AST::Apply;
{
    sub emit_begin_scratchpad_args {
        my $self = $_[0];
        return () if !$self->{arguments};
        return map { $_->emit_begin_scratchpad() } @{$self->{arguments}};
    }
    sub emit_begin_scratchpad {
        my $self = $_[0];   
        my $code;
        if (ref $self->{code}) {
            $code = $self->{code}->emit_begin_scratchpad();
        }
        else {
            $code = $self->{code};
        }
        my $arguments;
        if (ref $self->{arguments}) {
            $arguments = [ map { $_->emit_begin_scratchpad() } @{$self->{arguments}} ];
        }
        else {
            $arguments = $self->{arguments};
        }

        return __PACKAGE__->new(
            %$self,
            code => $code,
            arguments => $arguments,
        );
    }
}

package Perlito5::AST::If;
{
    sub emit_begin_scratchpad {
        my $self = $_[0]; 
        return __PACKAGE__->new(
            %$self,
            cond => $self->{cond}->emit_begin_scratchpad(),
            body => $self->{body}->emit_begin_scratchpad(),
            otherwise => $self->{otherwise}->emit_begin_scratchpad(),
        );
    }
}

package Perlito5::AST::When;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        return __PACKAGE__->new(
            %$self,
            cond => $self->{cond}->emit_begin_scratchpad(),
            body => $self->{body}->emit_begin_scratchpad(),
        );
    }
}


package Perlito5::AST::While;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        return __PACKAGE__->new(
            %$self,
            cond => $self->{cond}->emit_begin_scratchpad(),
            body => $self->{body}->emit_begin_scratchpad(),
        );
    }
}

package Perlito5::AST::For;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        my $cond;
        if (ref($self->{cond}) eq 'ARRAY') {
            # C-style for
            $cond = [ map { defined ? $_->emit_begin_scratchpad() : $_ } @{$self->{cond}} ];
        }
        else {
            $cond = $self->{cond}->emit_begin_scratchpad(),
        }
        return __PACKAGE__->new(
            %$self,
            cond => $cond,
            body => $self->{body}->emit_begin_scratchpad(),
            ( $self->{continue}
                ? ( continue => $self->{continue}->emit_begin_scratchpad() )
                : () ),
        );
    }
}

package Perlito5::AST::Decl;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];

        if (!$self->{var}{namespace} && $Perlito5::BEGIN_SCRATCHPAD{ $self->{var}{_id} || "" }) {
            return $self->{var}->emit_begin_scratchpad();
        }

        return __PACKAGE__->new(
            %$self,
            var  => $self->{var}->emit_begin_scratchpad(),
        );
    }
}

package Perlito5::AST::Sub;
{
    sub emit_begin_scratchpad {
        my $self = $_[0];
        my @stmts;
        if (defined $self->{block}) {
            @stmts = @{$self->{block}{stmts}};
            @stmts = map { $_->emit_begin_scratchpad() } @stmts;
            $self = __PACKAGE__->new(
                %$self,
                ( $self->{block}
                ? ( block => Perlito5::AST::Block->new(
                            %{$self->{block}},
                            stmts => [ @stmts ],
                         ) )
                : () ),
            );
        }
        return $self;
    }
}

package Perlito5::AST::Use;
{
    sub emit_begin_scratchpad {
        my $self = shift;
        return $self;
    }
}

1;

=begin

=head1 NAME

Perlito5::AST::CompileTime - Code generator for Perlito5-in-CompileTime

=head1 SYNOPSIS

    $program->emit_begin_scratchpad()  # generated CompileTime code

=head1 DESCRIPTION

This module generates CompileTime code for the Perlito compiler.
CompileTime code is the code that runs in BEGIN blocks.

=head1 AUTHORS

Flavio Soibelmann Glock <fglock@gmail.com>.

=head1 COPYRIGHT

Copyright 2016 by Flavio Soibelmann Glock.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end