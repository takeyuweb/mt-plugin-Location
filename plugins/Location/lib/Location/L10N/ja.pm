package Location::L10N::ja;

use strict;
use warnings;
use utf8;
use base 'Location::L10N::en_us';

use vars qw( %Lexicon );

%Lexicon = (
    '_PLUGIN_DESCRIPTION'
        => 'Movable Type で位置情報に基づく記事の検索・地図表示などを実現します。',
    'Location'
        => '位置情報',
    'Address or Keyword'
        => '住所 または キーワード',
    'Location is not found.'
        => '位置情報が見つかりませんでした。',
    'Map'
        => '地図',
    'Latitude'
        => '緯度',
    'Longitude'
        => '経度',
);

1;