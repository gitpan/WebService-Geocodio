use strict;
use warnings;

package WebService::Geocodio::Request;
$WebService::Geocodio::Request::VERSION = '0.01';
use Moo::Role;
use HTTP::Tiny;
use JSON;
use Carp qw(confess);
use WebService::Geocodio::Location;

# ABSTRACT: A request role for Geocod.io


has 'json' => (
    is => 'ro',
    lazy => 1,
    default => sub { JSON->new()->allow_blessed->convert_blessed },
);


has 'ua' => (
    is => 'ro',
    lazy => 1,
    default => sub { HTTP::Tiny->new(
        agent => 'WebService-Geocodio ',
        default_headers => { 'Content-Type' => 'application/json' },
    ) },
);


has 'base_url' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'http://api.geocod.io/v1/geocode' },
);


sub send {
    my $self = shift;

    my $data = $self->json->encode(shift);

    my $response = $self->ua->request('POST', $self->base_url . "?api_key=" . $self->api_key, { content => $data });

    if ( $response->{success} ) {
        my $hr = $self->json->decode($response->{content});
        return map { WebService::Geocodio::Location->new($_) } 
            map {; @{$_->{response}->{results}} } @{$hr->{results}};
    }
    else {
        confess "Request to " . $self->base_url . " failed: (" . $response->{status} . ") - " . $response->{content};
    }
}

1;

__END__

=pod

=head1 NAME

WebService::Geocodio::Request - A request role for Geocod.io

=head1 VERSION

version 0.01

=head1 ATTRIBUTES

=head2 json

A JSON serializer/deserializer object. Default is JSON.

=head2 ua

A user agent object. Default is HTTP::Tiny

=head2 base_url

The base url to use when connecting to the service. Default is 'http://api.geocod.io'

=head1 METHODS

=head2 send

This method sends an arrayref of data to the service for processing.  If the web call is
successful, returns an array of L<WebService::Geocodio::Location> objects.

Any API errors are fatal and reported by C<Carp::confess>.

=head1 AUTHOR

Mark Allen <mrallen1@yahoo.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Mark Allen.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
