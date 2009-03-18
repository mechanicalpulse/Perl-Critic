##############################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
##############################################################################

package Perl::Critic::Policy::Objects::ProhibitIndirectSyntax;

use 5.006001;
use strict;
use warnings;

use Carp;
use English qw(-no_match_vars);
use Perl::Critic::Utils qw{ :severities :classification };
use Readonly;

use base 'Perl::Critic::Policy';

our $VERSION = '1.098';

#-----------------------------------------------------------------------------

Readonly::Hash my %COMMA => {
    q<,> => 1,
    q{=>} => 1,
};
Readonly::Scalar my $DOLLAR => q<$>;

Readonly::Scalar my $DESC => 'Subroutine "%s" called using indirect syntax';
Readonly::Scalar my $EXPL => [ 349 ];

#-----------------------------------------------------------------------------

sub supported_parameters { return (
        {
            name => 'forbid',
            description => 'Indirect syntax is forbidden to these methods.',
            behavior => 'string list',
            list_always_present_values => [ qw{ new } ],
        }
    )
}

sub default_severity     { return $SEVERITY_HIGH             }
sub default_themes       { return qw( core pbp maintenance ) }
sub applies_to           { return 'PPI::Token::Word'         }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;

    # We are only interested in function calls.
    $elem or return;
    is_function_call( $elem ) or return;

    # We are only interested in the functions we have been told to check.
    $self->{_forbid}{$elem->content()} or return;

    # Per perlobj, it is only an indirect object call if the next sibling
    # is a word, a scalar symbol, or a block.
    my $object = $elem->snext_sibling() or return;
    $object->isa( 'PPI::Token::Word' )
        or $object->isa( 'PPI::Token::Symbol' )
            and $DOLLAR eq $object->raw_type()
        or $object->isa( 'PPI::Structure::Block' )
        or return;

    # Per perlobj, it is not an indirect object call if the operator after
    # the possible indirect object is a comma.
    if ( my $operator = $object->snext_sibling() ) {
        $operator->isa( 'PPI::Token::Operator' )
            and $COMMA{ $operator->content() }
            and return;
    }

    my $message = sprintf $DESC, $elem->content();
    return $self->violation( $message, $EXPL, $elem );

}

1;

__END__

#-----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::Objects::ProhibitIndirectSyntax - Prohibit indirect object call syntax.


=head1 AFFILIATION

This Policy is part of the core L<Perl::Critic|Perl::Critic>
distribution.


=head1 DESCRIPTION

Indirect object syntax is commonly used in other object-oriented languages for
instantiating objects. Perl allows this, but to say that it supports it may be
going too far. Instead of writing

 my $foo = new Foo;

it is preferable to write

 my $foo = Foo->new;

The problem is that Perl needs to make a number of assumptions at compile time
to disambiguate the first form, so it tends to be fragile and to produce
hard-to-track-down bugs.


=head1 CONFIGURATION

Indirect object syntax is also hard for Perl::Critic to disambiguate, so this
policy only checks certain subroutine calls. The names of the subroutines can
be configured using the C<forbid> configuration option:

 [Objects::ProhibitIndirectSyntax]
 forbid = create destroy

The C<new> subroutine is configured by default; any additional C<forbid>
values are in addition to C<new>.


=head1 CAVEATS

The general situation can not be handled.


=head1 AUTHOR

Thomas R. Wyant, III F<wyant at cpan dot org>


=head1 COPYRIGHT

Copyright 2009 Tom Wyant.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :

