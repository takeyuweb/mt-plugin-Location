package Location::Listing;

use strict;
use warnings;
use utf8;
use MT;
use MT::Util;

our $plugin = MT->component( 'Location' );

sub _use_location {
    my $prop = shift;
    my ( $obj, $app, $opts ) = @_;
    
    return $plugin->translate( 'Disabled' ) unless $obj->use_location;
    
    my $title   = MT::Util::encode_html( $obj->title, 1 );
    my $lat     = $obj->lat;
    my $lng     = $obj->lng;
    my $href = "http://maps.google.co.jp/maps?ie=UTF8&q=$lat,$lng&ll=$lat,$lng&z=15";
    
    return $plugin->translate( 'Enabled' ) . ' (<a href="'.$href.'" target="_blank">' . $plugin->translate( 'Map' ) . '</a>)';
}

sub _lat {
    my $prop = shift;
    my ( $obj, $app, $opts ) = @_;
    $obj->use_location ? $obj->lat : '';
}

sub _lng {
    my $prop = shift;
    my ( $obj, $app, $opts ) = @_;
    $obj->use_location ? $obj->lng : '';
}

1;