package Location::Tags;

use strict;
use warnings;
use utf8;

sub _hdlr_entry_if_potisioned {
    my ( $ctx, $args ) = @_;
    my $entry = $ctx->stash( 'entry' );
    return $ctx->_no_entry_error( 'MT' . $ctx->stash( 'tag' ) )
        unless defined $entry;
    $entry->use_location ? 1 : 0;
}

sub _hdlr_entry_lat {
    my ( $ctx, $args ) = @_;
    my $entry = $ctx->stash( 'entry' );
    return $ctx->_no_entry_error( 'MT' . $ctx->stash( 'tag' ) )
        unless defined $entry;
    return undef unless $entry->use_location;
    $entry->lat;
}

sub _hdlr_entry_lng {
    my ( $ctx, $args ) = @_;
    my $entry = $ctx->stash( 'entry' );
    return $ctx->_no_entry_error( 'MT' . $ctx->stash( 'tag' ) )
        unless defined $entry;
    return undef unless $entry->use_location;
    $entry->lng;
}

1;
