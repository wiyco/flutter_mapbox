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

[permission_handler](https://pub.dev/packages/permission_handler)で位置情報の許可を管理する。

> [!TIP]
>
> 写真フォルダの読み取りなど、他の許可もまとめて管理できるためこちらを使う。

### Permission設定

- [位置情報の利用許可 | Android](https://developer.android.com/training/location/permissions?hl=ja)
- [Bundle Resources | Apple Developer](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationwheninuseusagedescription)

> [!TIP]
>
> 下記はアプリを開いている時の許可
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

現在位置は[geolocator](https://pub.dev/packages/geolocator)で取得する。

> [!NOTE]
>
> Mapboxは現在位置にアイコンが表示されるため、メソッドから座標を取得しようとしたが見つからなかった

カメラ追従は自作する必要があるか。

Unityの`Update`メソッドのようなものがあればいいが。。。
