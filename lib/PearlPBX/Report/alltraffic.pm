#===============================================================================
#
#         FILE:  alltraffic.pm
#
#  DESCRIPTION:
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  01.06.2012 05:30:27 EEST
#===============================================================================

=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Report::alltraffic;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

#===============================================================================
#

=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

#***********************************************************************

=head1 OBJECT METHODS

=over

=item B<user(...)> - object method

=cut

#-----------------------------------------------------------------------
sub report {

    my $this = shift;

    my $sincedate = shift;
    my $sincetime = shift;
    my $tilldate  = shift;
    my $tilltime  = shift;
    my $direction = shift;

    my $sincedatetime = $this->filldatetime( $sincedate, $sincetime );
    my $tilldatetime  = $this->filldatetime( $tilldate,  $tilltime );
    my $sql_dir = $this->fill_direction_sql_condition($direction);

    my $sql =
"select calldate,src,channel,dst,dstchannel,disposition,billsec from public.cdr where calldate between ? and ? and $sql_dir order by calldate desc";

    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }

    my $hash_ref = $sth->fetchall_hashref('calldate');
    unless ($hash_ref) {
        return 0;
    }

    return $hash_ref;

}

1;

__END__

=back

=head1 EXAMPLES


=head1 BUGS

Unknown yet

=head1 SEE ALSO

None

=head1 TODO

None

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

