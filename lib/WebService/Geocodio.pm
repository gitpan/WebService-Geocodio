use strict;
use warnings;

package WebService::Geocodio;
$WebService::Geocodio::VERSION = '0.02';
use Moo;
use Carp qw(confess);
with('WebService::Geocodio::Request');

# ABSTRACT: A Perl interface to Geocod.io



has 'api_key' => (
    is => 'ro',
    isa => sub { confess "$_[0] doesn't look like a valid api key\n" unless $_[0] =~ /[0-9a-f]+/ },
    required => 1,
);


has 'locations' => (
    is => 'rw',
    default => sub { [] },
);


sub add_location {
    my $self = shift;

    push @{ $self->locations }, @_;
}


sub show_locations {
    my $self = shift;

    return @{ $self->locations };
}


sub clear_locations {
    my $self = shift;

    $self->locations([]);
}


sub geocode {
    my $self = shift;

    return undef if scalar @{$self->locations} < 1;

    my @r = $self->send($self->locations);

    wantarray ? return @r : return \@r;
}

1;

__END__

=pod

=head1 NAME

WebService::Geocodio - A Perl interface to Geocod.io

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    use 5.014;
    use WebService::Geocodio;
    use WebService::Geocodio::Location;

    my $geo = WebService::Geocodio->new(
        api_key => $ENV{GEOCODIO_API_KEY}
    );

    # Wrigley Field
    my $loc = WebService::Geocodio::Location->new(
        number => 1060,
        street => 'W Addison',
        suffix => 'Street',
        city => 'Chicago',
        state => 'IL',
    );

    # Could add more than one thing here, even bare strings are OK
    # 20050 = zip code in Washington DC
    $geo->add_location($loc, '20050');

    # prints:
    # Chicago: 41.947205791667, -87.656316875
    # Chicago: 41.947180613636, -87.657167363636
    # Washington: 38.893311, -77.014647

    map { say $_->city, ": ", $_->lat, ", ", $_->lng } $geo->geocode();

=head1 OVERVIEW

This module is a fairly thin wrapper around the L<Geocod.io|http://geocod.io> geocoding web service.
This service currently only supports US based addresses and "forward" geocoding where you have a postal
address and want to convert to latitude/longitude pair.  The library is somewhat finicky about 
how addresses are presented and stored; please read the API documentation thoroughly to make sure
you're getting the best quality results from the service.

More countries and reverse geocoding (lat/lng -> postal address) are planned for future releases.

You will need to obtain a free API key to use this library.

All errors are fatal and reported by confess.  If you want more graceful error handling, you might
want to try using L<Try::Tiny>.

=head1 ATTRIBUTES

=head2 api_key

This is the geocod.io API key. It is required.

=head2 locations

The list of locations you want to geocode.  These can be bare strings (if you like) or
you can use a fancy object like L<WebService::Geocodio::Location> which will serialize
itself to JSON automatically.

=head1 METHODS

=head2 add_location

This method takes one or more locations and stores it in the locations attribute.

=head2 show_locations

Show the locations currently set for geocoding.

=head2 clear_locations

If you want to clear the current list of locations, use this method.

=head2 geocode

Send the current list of locations to the geocod.io service.

Returns undef if there are no locations stored.

In a list context, returns a list of L<WebService::Geocodio::Location> objects.  In a scalar context,
returns an arrayref of L<WebService::Geocodio::Location> objects. The list of objects is presented
in descending order of accuracy.

=head1 AUTHOR

Mark Allen <mrallen1@yahoo.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Mark Allen.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
