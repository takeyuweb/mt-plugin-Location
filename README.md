Location プラグイン
==================

* Author:: Yuichi Takeuchi <info@takeyu-web.com>
* Website:: http://takeyu-web.com/
* Copyright:: Copyright 2013 Yuichi Takeuchi
* License:: MIT License

Movable Type 6 で位置情報に基づく記事の検索・地図表示などを実現します。

![利用イメージ](https://raw.github.com/uzuki05/mt-plugin-Location/master/edit_entry.png)

* ブログ記事編集画面に「位置情報」を追加
  * Google Map上のマーカーをドラッグ＆ドロップで指定可能
  * Geocoding APIを利用した名称・住所からの位置指定が可能
* Data APIに位置検索用のパラメータを追加
  * 指定地点から半径○km
* 位置情報表示用のテンプレートタグを提供（スタティック/ダイナミック）


## Data API

### Entries list

記事一覧取得APIで以下のパラメータを指定できるようになります。
指定しない場合は標準の動作となります。

| パラメータ | 種類         | デフォルト | 説明                  |
|:-----------|:-------------|:-----------|:----------------------|
| lat        | float        |            | 中心点の緯度（WGS84） |
| lng        | float        |            | 中心点の経度（WGS84） |
| distance   | float        | 1.0        | 検索半径（km）        |

    http://test.host/mt/mt-data-api.cgi/v1/sites/1/entries?lat=35.710139&lng=139.810833&distance=1.0


### Entries resource

Data APIから返却される記事リソースに以下のプロパティが追加されます。

| プロパティ   | 種類         | データ種別   | カラム                | 読込専用 | 説明                  |
|:-------------|:-------------|:-------------|:----------------------|:---------|:----------------------|
| useLocation  | value        | Boolean      | mt_entry.use_location |          | 位置情報有効フラグ    |
| lat          | value        | float        | mt_entry.lat          |          | 緯度（WGS84）         |
| lng          | value        | float        | mt_entry.lng          |          | 経度（WGS84）         |


## テンプレートタグ

スタティックパブリッシング・ダイナミックパブリッシングのどちらでも使用できます。

### コンディショナルタグ

#### MTEntryIfPositioned

記事の位置情報が「有効」のときブロック内を処理

### ファンクションタグ

#### MTEntryLat

記事の緯度を表示

#### MTEntryLng

記事の経度を表示

### 使用例

    <mt:EntryIfPositioned>
        緯度:<$MTEntryLat$>
        経度:<$MTEntryLng$>
        <a href=http://maps.google.co.jp/maps?ie=UTF8&q=<$MTEntryLat$>,<$MTEntryLng$>&ll=<$MTEntryLat$>,<$MTEntryLng$>&z=15";>GoogleMap</a>
    </mt:EntryIfPositioned>

## TODO

できればやりたいこと。（無理っぽいことも含まれる）

* 検索
  * 指定地点からの距離を取得
  * 指定地点からの近い順でソート
* テンプレートタグ
  * 測地系変換モディファイア
  * 度分秒表記モディファイア
* 管理
  * Listing Frameworkで位置検索

##Contributing to Location

Fork, fix, then send me a pull request.

##Copyright

© 2013 Yuichi Takeuchi, released under the MIT license
