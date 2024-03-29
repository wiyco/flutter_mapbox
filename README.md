# Flutter Mapbox

## 環境変数

### dotenv

[flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

#### `.env.local`を作成

```shell
MAPBOX_PUBLIC_TOKEN=your_public_token
```

#### `.env*`の読み込み

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.local');
  runApp(const MyApp());
}
```

> [!CAUTION]
>
> アプリ公開前に`.env*`ファイルを削除する必要がある
>
> アプリにはプロジェクト内全てのファイルが含まれている

#### 変数の使い方

```dart
final String mapboxPublicToken = dotenv.get('MAPBOX_PUBLIC_TOKEN');
```

### Mapbox

Mapは[mapbox_maps_flutter](https://pub.dev/packages/mapbox_maps_flutter)を使う (公式の`mapbox_gl`ではない←開発打ち切りで古い)

PublicとSecret両方のトークンが必要 (Publicトークンは前述で追加済み)

- Public token (Default)
- Secret token with the `DOWNLOADS:READ` scope (Create)

#### Android

`~/.gradle/gradle.properties`

```shell
SDK_REGISTRY_TOKEN=your_secret_token
```

> [!TIP]
>
> `~`は`/Users/(username)`

#### iOS

`~/.netrc`

```shell
machine api.mapbox.com
  login mapbox
  password your_secret_token
```

> [!NOTE]
>
> SecretトークンはGitのスコープから外れるため漏洩の心配は必要ない

## ビルド設定

### Mapbox

#### Android

`(project)/android/app/build.gradle`

```groovy
android {
  defaultConfig {
      // mapbox_maps_flutter
      minSdkVersion 21
  }
}
```

## 位置情報

[permission_handler](https://pub.dev/packages/permission_handler)で位置情報の許可を管理する

> [!NOTE]
>
> 写真フォルダの読み取りなど、他の許可もまとめて管理できるためこちらを使う

### Permission設定

- [位置情報の利用許可 | Android](https://developer.android.com/training/location/permissions?hl=ja)
- [Bundle Resources | Apple Developer](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationwheninuseusagedescription)

> [!TIP]
>
> 下記はアプリを開いている時の許可設定
>
> バックグラウンドでの許可は[geolocatorのドキュメント](https://pub.dev/packages/geolocator#usage)がわかりやすい

#### Android

`(project)/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- geolocation -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
</manifest>
```

#### iOS

`(project)/ios/Runner/Info.plist`

```xml
<dict>
	<!-- geolocation -->
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>This app needs access to location when open.</string>
</dict>
```

### 現在位置

[geolocator](https://pub.dev/packages/geolocator)を使う

> [!NOTE]
>
> Mapboxは現在位置を表示できることから、メソッドの座標を取得しようとしたが見つからなかった

カメラ追従は`geolocator`の`getPositionStream`を使うことで実現できる

さらに`LocationSettings`の`distanceFilter`にて、Stream間隔をメートル単位で制御できる

詳細は[geolocatorのドキュメント](https://pub.dev/packages/geolocator#listen-to-location-updates)を参照

> [!IMPORTANT]
>
> [mapbox_maps_flutter](https://pub.dev/packages/mapbox_maps_flutter)と[geolocator](https://pub.dev/packages/geolocator)の`Position`クラス被りにより、どちらかにprefixをつけなければならない
> ```dart
> import 'package:geolocator/geolocator.dart' as gl;
> import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
> 
> gl.Position? currentPosition;
> ```

> [!NOTE]
>
> 初回起動時は、位置情報の許可＋座標(0,0)から現在地にカメラを飛ばすため、カメラ追従の初期化に時間がかかる
>
> ここは、ローディングオーバーレイを表示するのが最適か

## Riverpod

- [超絶優良記事](https://zenn.dev/norimaki0631/articles/b23a37354d3409)
- [公式ドキュメント](https://riverpod.dev/docs/introduction/getting_started)

### VSCode Extensions

- [Flutter Riverpod Snippets](https://marketplace.visualstudio.com/items?itemName=robert-brunhage.flutter-riverpod-snippets)

### Code Generation

[Code generation](https://riverpod.dev/docs/concepts/about_code_generation)やべえ

> [!TIP]
>
> Code generationでは、プロジェクトを開いた後に以下を実行しなければならない
>
> 詳細は[build_runnerのドキュメント](https://pub.dev/packages/build_runner#docs)

`*.g.dart`ファイルのビルドを自動で行う

```shell
dart run build_runner watch --delete-conflicting-outputs
```

> [!IMPORTANT]
>
> コンソールは複数起動できるので、`flutter run`しながら上記を実行可

> [!NOTE]
>
> Nodeの`package.json`みたく`scripts`を定義しようとしたが、`pubspec.yaml`にはない
>
> `derry`, `rps`などは、`dart pub global activate`が必要なため断念

## Freezed

flutterはモデルを定義する機能が弱い

そのため、モデルクラスを定義する際は[freezed](https://pub.dev/packages/freezed)を使う

- [超絶優良記事](https://zenn.dev/joo_hashi/books/2c6c47e3d79b63/viewer/79d890)

***調査中...***

## Retrofit

Apiとの通信では[retrofit](https://pub.dev/packages/retrofit)を使う

***調査中...***

---

## 設計

[ドメイン駆動設計(DDD/Domain-Driven Design)](https://zenn.dev/midman/articles/0b802fdfeb889b)が良い？

***調査中...***

---

🦊
