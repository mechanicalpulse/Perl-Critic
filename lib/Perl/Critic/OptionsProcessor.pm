##############################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
##############################################################################

package Perl::Critic::OptionsProcessor;

use strict;
use warnings;

use English qw(-no_match_vars);

use Perl::Critic::Utils qw{
    :booleans :characters :severities :data_conversion $DEFAULT_VERBOSITY
};
use Perl::Critic::Exception::AggregateConfiguration;
use Perl::Critic::Exception::Configuration::Option::Global::ExtraParameter;
use Perl::Critic::Utils::Constants qw{ $PROFILE_STRICTNESS_DEFAULT };

our $VERSION = '1.083_003';

#-----------------------------------------------------------------------------

sub new {

    my ($class, %args) = @_;
    my $self = bless {}, $class;
    $self->_init( %args );
    return $self;
}

#-----------------------------------------------------------------------------

sub _init {

    my ( $self, %args ) = @_;

    # Multi-value defaults
    my $exclude = delete $args{exclude} || $EMPTY;
    $self->{_exclude}    = [ words_from_string( $exclude ) ];
    my $include = delete $args{include} || $EMPTY;
    $self->{_include}    = [ words_from_string( $include ) ];

    # Single-value defaults
    $self->{_force}          = delete $args{force}            || $FALSE;
    $self->{_only}           = delete $args{only}             || $FALSE;
    $self->{_profile_strictness} =
        delete $args{'profile-strictness'} || $PROFILE_STRICTNESS_DEFAULT;
    $self->{_single_policy}  = delete $args{'single-policy'}  || $EMPTY;
    $self->{_severity}       = delete $args{severity}         || $SEVERITY_HIGHEST;
    $self->{_theme}          = delete $args{theme}            || $EMPTY;
    $self->{_top}            = delete $args{top}              || $FALSE;
    $self->{_verbose}        = delete $args{verbose}          || $DEFAULT_VERBOSITY;
    $self->{_color}          = delete $args{color}            || $TRUE;
    $self->{_criticism_fatal} = delete $args{'criticism-fatal'} || $FALSE;

    # If there's anything left, complain.
    _check_for_extra_options(%args);

    return $self;
}

#-----------------------------------------------------------------------------

sub _check_for_extra_options {
    my %args = @_;

    if ( my @remaining = sort keys %args ){
        my $errors = Perl::Critic::Exception::AggregateConfiguration->new();

        foreach my $option_name (@remaining) {
            $errors->add_exception(
                Perl::Critic::Exception::Configuration::Option::Global::ExtraParameter->new(
                    option_name     => $option_name,
                )
            )
        }

        $errors->rethrow();
    }

    return;
}

#-----------------------------------------------------------------------------
# Public ACCESSOR methods

sub severity {
    my ($self) = @_;
    return $self->{_severity};
}

#-----------------------------------------------------------------------------

sub theme {
    my ($self) = @_;
    return $self->{_theme};
}

#-----------------------------------------------------------------------------

sub exclude {
    my ($self) = @_;
    return $self->{_exclude};
}

#-----------------------------------------------------------------------------

sub include {
    my ($self) = @_;
    return $self->{_include};
}

#-----------------------------------------------------------------------------

sub only {
    my ($self) = @_;
    return $self->{_only};
}

#-----------------------------------------------------------------------------

sub profile_strictness {
    my ($self) = @_;
    return $self->{_profile_strictness};
}

#-----------------------------------------------------------------------------

sub single_policy {
    my ($self) = @_;
    return $self->{_single_policy};
}

#-----------------------------------------------------------------------------

sub verbose {
    my ($self) = @_;
    return $self->{_verbose};
}

#-----------------------------------------------------------------------------

sub color {
    my ($self) = @_;
    return $self->{_color};
}

#-----------------------------------------------------------------------------

sub criticism_fatal {
    my ($self) = @_;
    return $self->{_criticism_fatal};
}

#-----------------------------------------------------------------------------

sub force {
    my ($self) = @_;
    return $self->{_force};
}

#-----------------------------------------------------------------------------

sub top {
    my ($self) = @_;
    return $self->{_top};
}


1;

__END__

#-----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::OptionsProcessor - The global configuration default values, combined with command-line values.

=head1 DESCRIPTION

This is a helper class that encapsulates the default parameters for
constructing a L<Perl::Critic::Config> object.  There are no
user-serviceable parts here.

=head1 CONSTRUCTOR

=over 8

=item C< new( %DEFAULT_PARAMS ) >

Returns a reference to a new C<Perl::Critic::OptionsProcessor> object.  You
can override the coded defaults by passing in name-value pairs that
correspond to the methods listed below.

This is usually only invoked by L<Perl::Critic::UserProfile>, which
passes in the global values from a F<.perlcriticrc> file.  This object
contains no information for individual Policies.

=back

=head1 METHODS

=over 8

=item C< exclude() >

Returns a reference to a list of the default exclusion patterns.  If
there are no default exclusion patterns, then the list will be empty.

=item C< force() >

Returns the default value of the C<force> flag (Either 1 or 0).

=item C< include() >

Returns a reference to a list of the default inclusion patterns.  If
there are no default exclusion patterns, then the list will be empty.

=item C< only() >

Returns the default value of the C<only> flag (Either 1 or 0).

=item C< profile_strictness() >

Returns the default value of C<profile_strictness> as an unvalidated
string.

=item C< single_policy() >

Returns the default C<single-policy> pattern.  (As a string.)

=item C< severity() >

Returns the default C<severity> setting. (1..5).

=item C< theme() >

Returns the default C<theme> setting. (As a string).

=item C< top() >

Returns the default C<top> setting. (Either 0 or a positive integer).

=item C< verbose() >

Returns the default C<verbose> setting. (Either a number or format
string).

=item C< color() >

Returns the default C<color> setting. (Either 1 or 0).

=item C< criticism_fatal() >

Returns the default C<criticism-fatal> setting (Either 1 or 0).

=back

=head1 SEE ALSO

L<Perl::Critic::Config>, L<Perl::Critic::UserProfile>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2008 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :