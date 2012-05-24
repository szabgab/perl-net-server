# -*- perl -*-
#
#  Net::Server::Proto::UNIXDGRAM - Net::Server Protocol module
#
#  $Id$
#
#  Copyright (C) 2011
#
#    Paul Seamons
#    paul@seamons.com
#    http://seamons.com/
#
#  This package may be distributed under the terms of either the
#  GNU General Public License
#    or the
#  Perl Artistic License
#
#  All rights reserved.
#
################################################################

package Net::Server::Proto::UNIXDGRAM;

use strict;
use base qw(Net::Server::Proto::UNIX);
use Socket qw(SOCK_DGRAM);

sub NS_proto { 'UNIXDGRAM' }
sub NS_recv_len   { my $sock = shift; ${*$sock}{'NS_recv_len'}   = shift if @_; return ${*$sock}{'NS_recv_len'}   }
sub NS_recv_flags { my $sock = shift; ${*$sock}{'NS_recv_flags'} = shift if @_; return ${*$sock}{'NS_recv_flags'} }
sub NS_unix_type { 'SOCK_DGRAM' }

sub object {
    my ($class, $info, $server) = @_;

    my ($len, $flags);
    $server->configure({
        udp_recv_len   => \$len,
        udp_recv_flags => \$flags,
    });
    $len   = defined($info->{'udp_recv_len'})   ? $info->{'udp_recv_len'}   : (defined($len)   && $len   =~ /^(\d+)$/) ? $1 : 4096;
    $flags = defined($info->{'udp_recv_flags'}) ? $info->{'udp_recv_flags'} : (defined($flags) && $flags =~ /^(\d+)$/) ? $1 : 0;

    my $sock = $class->SUPER::new();
    $sock->NS_port($info->{'port'});
    $sock->NS_recv_len($len);
    $sock->NS_recv_flags($flags);
    return $sock;
}

sub connect {
    my ($sock, $server) = @_;
    my $path = $sock->NS_port;
    $server->fatal("Can't connect to UNIXDGRAM socket at file $path [$!]") if -e $path && ! unlink $path;

    $sock->SUPER::configure(
        Local  => $path,
        Type   => SOCK_DGRAM,
    ) or $server->fatal("Can't connect to UNIXDGRAM socket at file $path [$!]");
}

1;

__END__

=head1 NAME

  Net::Server::Proto::UNIXDGRAM - adp0 - Net::Server UNIXDGRAM protocol.

=head1 SYNOPSIS

See L<Net::Server::Proto>.

=head1 DESCRIPTION

Protocol module for Net::Server.  This module implements the
UNIX SOCK_DGRAM socket type.
See L<Net::Server::Proto>.

Any sockets created during startup will be chown'ed to the
user and group specified in the starup arguments.

=head1 PARAMETERS

The following paramaters may be specified in addition to
normal command line parameters for a Net::Server.  See
L<Net::Server> for more information on reading arguments.

=over 4

=item udp_recv_len

Specifies the number of bytes to read from the SOCK_DGRAM connection
handle.  Data will be read into $self->{'server'}->{'udp_data'}.
Default is 4096.  See L<IO::Socket::INET> and L<recv>.

=item udp_recv_flags

See L<recv>.  Default is 0.

=back

=head1 QUICK PARAMETER LIST

  Key               Value                    Default

  ## UNIXDGRAM socket parameters
  udp_recv_len      \d+                      4096
  udp_recv_flags    \d+                      0

=head1 LICENCE

Distributed under the same terms as Net::Server

=cut