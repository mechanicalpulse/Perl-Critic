#!perl

##############################################################################
#     $URL$
#    $Date$
#   $Author$
# $Revision$
##############################################################################

use strict;
use warnings;
use Test::More tests => 12;

# common P::C testing tools
use Perl::Critic::TestUtils qw(pcritique);
Perl::Critic::TestUtils::block_perlcriticrc();

my $code ;
my $policy;
my %config;

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
my $string =~ m{pattern}m;
my $string =~ m{pattern}gimx;
my $string =~ m{pattern}gmis;
my $string =~ m{pattern}mgxs;

my $string =~ m/pattern/m;
my $string =~ m/pattern/gimx;
my $string =~ m/pattern/gmis;
my $string =~ m/pattern/mgxs;

my $string =~ /pattern/m;
my $string =~ /pattern/gimx;
my $string =~ /pattern/gmis;
my $string =~ /pattern/mgxs;

my $string =~ s/pattern/foo/m;
my $string =~ s/pattern/foo/gimx;
my $string =~ s/pattern/foo/gmis;
my $string =~ s/pattern/foo/mgxs;
END_PERL

$policy = 'RegularExpressions::RequireLineBoundaryMatching';
is( pcritique($policy, \$code), 0, $policy);

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
my $string =~ m{pattern};
my $string =~ m{pattern}gix;
my $string =~ m{pattern}gis;
my $string =~ m{pattern}gxs;

my $string =~ m/pattern/;
my $string =~ m/pattern/gix;
my $string =~ m/pattern/gis;
my $string =~ m/pattern/gxs;

my $string =~ /pattern/;
my $string =~ /pattern/gix;
my $string =~ /pattern/gis;
my $string =~ /pattern/gxs;

my $string =~ s/pattern/foo/;
my $string =~ s/pattern/foo/gix;
my $string =~ s/pattern/foo/gis;
my $string =~ s/pattern/foo/gxs;

END_PERL

$policy = 'RegularExpressions::RequireLineBoundaryMatching';
is( pcritique($policy, \$code), 16, $policy);

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
my $string =~ tr/[A-Z]/[a-z]/;
my $string =~ tr|[A-Z]|[a-z]|;
my $string =~ tr{[A-Z]}{[a-z]};

my $string =~ y/[A-Z]/[a-z]/;
my $string =~ y|[A-Z]|[a-z]|;
my $string =~ y{[A-Z]}{[a-z]};

my $string =~ tr/[A-Z]/[a-z]/cds;
my $string =~ y/[A-Z]/[a-z]/cds;
END_PERL

$policy = 'RegularExpressions::RequireExtendedFormatting';
is( pcritique($policy, \$code), 0, $policy);

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
my $string =~ tr/[A-Z]/[a-z]/;
my $string =~ tr|[A-Z]|[a-z]|;
my $string =~ tr{[A-Z]}{[a-z]};

my $string =~ y/[A-Z]/[a-z]/;
my $string =~ y|[A-Z]|[a-z]|;
my $string =~ y{[A-Z]}{[a-z]};

my $string =~ tr/[A-Z]/[a-z]/cds;
my $string =~ y/[A-Z]/[a-z]/cds;
END_PERL

$policy = 'RegularExpressions::RequireLineBoundaryMatching';
is( pcritique($policy, \$code), 0, $policy);

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
my $foo = $1;
my @matches = ($1, $2);
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 3, $policy );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
$1
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 1, $policy );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
'some string' =~ m/(s)/;
my $s = $1;
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 1, $policy );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
if (m/(.)/) {
   'some string' =~ m/(s)/;
   my $s = $1;
}
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 1, $policy );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
if ($str =~ m/(.)/) {
   return $1;
}
elsif ($foo =~ s/(b)//) {
   $bar = $1;
}

if ($str =~ m/(.)/) {
   while (1) {
      return $1;
   }
}

while ($str =~ m/\G(.)/cg) {
   print $1;
}

print $0; # not affected by policy
print $_; # not affected by policy
print $f1; # not affected by policy

my $result = $str =~ m/(.)/;
if ($result) {
   return $1;
}
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 0, $policy );

#-----------------------------------------------------------------------------

$code = <<'END_PERL';
print m/(.)/ ? $1 : 'undef';
print !m/(.)/ ? 'undef' : $1;
print s/(.)// ? $1 : 'undef';
print !s/(.)// ? 'undef' : $1;
$foo = m/(.)/ && $1;
$foo = !m/(.)/ || $1;
$foo = s/(.)// && $1;
$foo = !s/(.)// || $1;
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 0, $policy );

#-----------------------------------------------------------------------------

# Regression for PPI::Statement::Expressions

$code = <<'END_PERL';
if (m/(\d+)/xms) {
   $foo = ($1);
}
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 0, $policy );

#-----------------------------------------------------------------------------

# Regression for ternaries with structures

$code = <<'END_PERL';
$str =~ m/(.)/xms ? foo($1) : die;
$str =~ m/(.)/xms ? [$1] : die;
$str =~ m/(.)/xms ? { match => $1 } : die;
END_PERL

$policy = 'RegularExpressions::ProhibitCaptureWithoutTest';
is( pcritique($policy, \$code), 0, $policy );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
