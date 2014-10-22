use 5.014;
use WebService::Geocodio;
use WebService::Geocodio::Location;
use Data::Dumper;

use Test::More;

BEGIN { 
    if (! $ENV{GEOCODIO_API_KEY} ) {
        plan skip_all => "Set GEOCODIO_API_KEY to run these tests.";
    }
    else {
        plan tests => 4;
    }
};

my $geo = WebService::Geocodio->new(
    api_key => $ENV{GEOCODIO_API_KEY}
);
    
# Chicago, IL
my $loc = WebService::Geocodio::Location->new(
    lat => 41.947205791667,
    lng => -87.656316875
);

$geo->add_location($loc);
$geo->add_field('timezone', 'foobar');
    
my @r = $geo->reverse_geocode();

is($r[0]->state, 'IL', "Got right state (IL)");
is($r[0]->fields->{'timezone'}->{'name'}, 'CST', "Got right timezone (CST)");

$geo->clear_locations();

# Washington DC
$geo->add_location('38.893311,-77.014647');

my $s = $geo->reverse_geocode();
is($s->[0]->city, 'Washington', "Got right city (Washington)");
is($s->[0]->fields->{timezone}->{name}, 'EST', "Got right timezone (EST)");

