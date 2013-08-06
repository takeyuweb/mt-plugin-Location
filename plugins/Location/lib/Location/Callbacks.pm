package Location::Callbacks;

use strict;
use warnings;
use utf8;
use MT;

our $plugin = MT->component( 'Location' );

sub _cb_ts_edit_entry {
    my ( $cb, $app, $ref_tmpl ) = @_;
    my $q = $app->param;
    return 1 unless $q->param( '_type' ) eq 'entry';
    
    $$ref_tmpl = <<'TMPL' . $$ref_tmpl;
<mt:SetVarBlock name="html_head" append="1">
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
</mt:SetVarBlock>
TMPL
    
    my $impl = <<'TMPL';
<mt:setvarblock name="jq_js_include" append="1">
<__trans_section component="Location">
function _LocationController() {
    var form = jQuery('#entry_form');
    this.latField = form.find("input[name=lat]");
    this.lngField = form.find("input[name=lng]");
    var latlng = new google.maps.LatLng(this.latField.val(), this.lngField.val());
    var mapOptions = {
        zoom: 15,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: true,
        mapTypeControlOptions: {
            mapTypeIds: [
                google.maps.MapTypeId.ROADMAP,
                google.maps.MapTypeId.SATELLITE,
                google.maps.MapTypeId.HYBRID,
                google.maps.MapTypeId.TERRAIN
            ]
        },
        enableContinuousZoom: true,
        enableDoubleClickZoom: true
    };
    
    this.map = new google.maps.Map(jQuery('#map_canvas')[0], mapOptions);
    jQuery(window).unload = google.maps.Unload;
    
    this.marker = new google.maps.Marker({
        position: latlng,
        map: this.map,
        title: "<__trans phrase='Location'/>",
        draggable: true
    });

    (function (obj) {
        var obj = obj;
        google.maps.event.addListener(obj.marker, 'dragend', function (position) {
            obj.updatePosition(position.latLng);
        });
    })(this);
    
};

_LocationController.prototype.geocoding = function (str) {
    var keyword = str;
    var geocoder = new google.maps.Geocoder();
    var obj = this;
    geocoder.geocode({ address: keyword }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK && results[0]) {
            obj.moveMarker(results[0].geometry.location);
        } else {
            window.alert("<__trans phrase='Location is not found.'/>");
        }
    });
};

_LocationController.prototype.moveMarker = function (position) {
    this.updatePosition(position);
    this.marker.setPosition(position);
    this.map.setZoom(15);
    this.map.panTo(position);
}

_LocationController.prototype.updatePosition = function (position) {
    this.latField.val(position.lat());
    this.lngField.val(position.lng());
};

var _location_controller;
google.load("maps", "3.x", {
    "other_params" : "sensor=false",
    "callback" : function (){
        _location_controller = new _LocationController();
    }
});

jQuery(document).on('click', '#geocodingstart', function(){
    _location_controller.geocoding(jQuery('input#geocodingkeyword').val());
});
jQuery(document).on('keypress', 'input#geocodingkeyword', function(e){
    if (e.keyCode == 13) {
        jQuery('#geocodingstart').click();
        if (e.preventDefault) {
            e.preventDefault();
        } else {
            e.returnValue = false;
        }
    }
});
</__trans_section>
</mt:setvarblock>
TMPL
    my $snippet = quotemeta('<mt:include name="include/footer.tmpl" id="footer_include">');
    $$ref_tmpl =~ s/($snippet)/$impl$1/;
}

sub _cb_tp_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $q = $app->param;
    return 1 unless $q->param( '_type' ) eq 'entry';
    
    my $html = <<"HTML";
<__trans_section component="Location">
    <mt:if name="use_location">
        <input type="radio" id="use_location_0" name="use_location" value="0"><label for="use_location_0"><__trans phrase="Disable"></label>
        <input type="radio" id="use_location_1" name="use_location" value="1" checked><label for="use_location_1"><__trans phrase="Enable"></label>
    <mt:Else>
        <input type="radio" id="use_location_0" name="use_location" value="0" checked><label for="use_location_0"><__trans phrase="Disable"></label>
        <input type="radio" id="use_location_1" name="use_location" value="1"><label for="use_location_1"><__trans phrase="Enable"></label>
    </mt:if>
    <div id="location-field">
        <__trans phrase="Address or Keyword">: <input type="text" id="geocodingkeyword" name="geocodingkeyword" value="" style="width: 200px;"/>
        <input id="geocodingstart" type="button" value="<__trans phrase='Search'>" />
        <div id="map_canvas" style="width: 100%; height: 400px;"></div>
        <input type="hidden" id="lat" name="lat" value="<mt:var name='lat'>" />
        <input type="hidden" id="lng" name="lng" value="<mt:var name='lng'>" />
    </div>
</__trans_section>
HTML
    
    push @{ $param->{ field_loop } }, {
        field_id    => 'location',
        lock_field  => '0',
        field_name  => 'location',
        show_field  => '1',
        field_label => $plugin->translate( 'Location' ),
        label_class => 'top-label',
        required    => '0',
        field_html  => $html
    };
}

sub _cb_data_api_pre_load_filtered_list_entry {
    my ( $cb, $app, $filter, $ref_options, $ref_cols ) = @_;
    my $q = $app->param;
    my $lat = $q->param( 'lat' );
    my $lng = $q->param( 'lng' );
    my $distance = $q->param( 'distance' ) || 1.0;
    return 1 unless ( defined( $lat ) && $lat ne '' && defined( $lng ) && $lng ne '' );
    
    my $ds = $filter->object_ds;
    my $terms = $ref_options->{ terms };
    my @ids = _fetch_ids( $app, $ds, $lat, $lng, $distance );
    
    if ( ref( $terms ) eq 'ARRAY' ) {
        if ( @ids ) {
            push @$terms, [ '-and', [ map{ ({ id => $_ }, '-or') } @ids ] ];
        } else {
            push @$terms, [ '-and', [ { id => -1 } ] ];
        }
    } elsif ( ref( $terms ) eq 'HASH' ) {
        if ( @ids ) {
            $terms = { %$terms, ( id => \@ids ) };
        } else {
            $terms = { %$terms, ( id => -1 ) };
        }
    } else {
        if ( @ids ) {
            $terms = { id => \@ids };
        } else {
            $terms = { id => -1 };
        }
    }
    $ref_options->{ terms } = $terms;
    1;
}


sub _fetch_ids {
    my ( $app, $ds, $lat, $lng, $distance ) = @_;
    my $q = $app->param;
    my $class = MT->model( $ds );
    my $blog_id   = $app->blog ? $app->blog->id : 0;
    my $id_column = 'id';
    
    my $stmt = $class->driver->dbd->sql_class->new;
    my $decorate = $stmt->field_decorator($class);
    $stmt->from( [sprintf('(SELECT * FROM %s WHERE entry_status = %d AND entry_use_location IS NOT NULL AND entry_use_location = 1 AND entry_lat IS NOT NULL AND entry_lng IS NOT NULL) locational_entry', $class->table_name(), MT::Entry::RELEASE())] );
    
    $stmt->add_select( '( 6371.0 * acos( cos( radians(?) ) * cos( radians( entry_lat ) ) * cos( radians( entry_lng ) - radians(?) ) + sin( radians(?) ) * sin( radians( entry_lat ) ) ) ) AS distance' );

    my @column_names = @{$class->column_names()};
    foreach my $column_name (@column_names) {
        $stmt->add_select( $decorate->($column_name) );
    }
    unshift @column_names, 'distance';
    
    $stmt->having( ['distance <= ?'] );
    $stmt->order( { column => 'distance', desc => 'ASC' } );
    
    my $driver = $class->driver;
    
    my $sql = $stmt->as_sql;
    my $dbh = $driver->r_handle;
    $driver->start_query( $sql, [ $lat, $lng, $lat, $distance ] );
    my $sth = $dbh->prepare_cached( $sql );
    $sth->execute(@{ [ $lat, $lng, $lat, $distance ] });

    # 値を取得
    # bind する場合は fetchの度に bind_columns で指定した変数に値がセットされる
    my @bindvars;
    my $col_count = scalar @{ $stmt->select };
    for ( 0 .. $col_count ) {
        push @bindvars, \my($var);
    }
    $sth->bind_columns( @bindvars ); # @bindvars = ('1列目の値', '2列目の値', ...);
    
    my $no_triggers = 0;
    my @ids = ();
    while ($sth->fetch()) {
        my $rec = {};
        my @returnvals = map { $$_ } @bindvars;
        for (my $i=0; $i<@returnvals; $i++) {
            $rec->{ $column_names[$i] } = $returnvals[$i];
        }
        #my $entry = $driver->load_object_from_rec($class, $rec, $no_triggers);
        #push @entries, $entry;
        push @ids, $rec->{ id };
    }
    $sth->finish;
    undef $sth;
    $driver->end_query($sth);
    
    return @ids;
}

1;