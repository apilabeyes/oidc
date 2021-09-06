# Flutter+AppAuthプラグインを使ったOIDCログインサンプル

KeycloadなどのOIDC対応のIdPと連携してログインし、トークンを取得するサンプルアプリのFlutterのサンプルコードです。

[OpenID Foundation](https://openid.net/) のオフィシャルGithubサイト [OpenID](https://github.com/openid) にある [Android版AppAuth](https://github.com/openid/AppAuth-Android) と [iOS版AppAuth](https://github.com/openid/AppAuth-iOS) をベースに開発された [Flutter版AppAuth](https://github.com/MaikuB/flutter_appauth) である [flutter_appauthプラグイン](https://pub.dev/packages/flutter_appauth) を利用して、それなりの品質 & 低コストで開発することが可能です。

## 前提条件
1. インターネット経由でアクセス可能な管理者権限をもったKeycloakの環境が用意されていること(参考: https://www.keycloak.org/docs/latest/server_installation/)
2. Flutterの環境がインストールされていること(参考: https://flutter.dev/docs/get-started/install)
3. Flutterのサンプルアプリを、開発PC経由でAndroid端末及びiPhoneに対して"flutter run"コマンドでコンパイル&実行することができること(iPhoneで試す場合は当然Apple Developerのライセンス取得やXCodeの設定等が必要なのでこのあたりの操作に慣れていることが必要です)

## 導入手順
1. [Keycloakのドキュメント](https://www.keycloak.org/docs/latest/server_admin/)を参照して、レルム作成と設定、一般ユーザの作成、クライアントの作成を行います。Webから作成した一般ユーザのアカウントにOIDCログインができるようにします。レルム管理者と一般ユーザのログインURLは下記の通りです。

- レルム管理者ログインURL: https://[Keycloakへのアドレス]/auth/admin/[レルム名]/console/
- 一般ユーザログインURL: https://[Keycloakへのアドレス]/auth/realms/[レルム名]/account

2. FlutterのAppAuthに設定する値をKeycloakにあわせて取得します。あとで使うのでどこかにメモしておきましょう。

- クライアント名(CLIENT_NAME)とクライアントシークレット(CLIENT_SECRET)
- ディスカバリURL(DISCOVERY_URL): https://[Keycloakへのアドレス]/auth/realms/apilabeyes/.well-known/openid-configuration の形式になります。
- リダイレクトURL(REDIRECT_URL): カスタムスキーマといい、ネイティブアプリがWebViewを開いて処理が終わったらWebViewをクローズしてネイティブアプリに操作を戻すトリガーに使います。"[何らかの文字列]://callback"という形式をとり、ここでは"oidc://callback"としています。"://callback"部分はiOS用に設定する値でこのような形式の文字列がないとiOSでWebViewはクローズしません。一方、Androidでは後述する「build.gradle」ファイルと「AndroidManifest.xml」ファイルにリダイレクトURLを設定しますが、"://callback"を除いた値"oidc"を設定します。

3. 本リポジトリをcloneして持ってきます。

```
$ git clone https://github.com/apilabeyes/oidc.git
```

4. "lib/main.dart"ファイルを開き、下記の箇所を上述2の通り編集します。
```
  var CLIENT_NAME = "(クライアント名)";
  var CLIENT_SECRET = "(クライアントシークレット)";
  var DISCOVERY_URL = "(ディスカバリURL)";
  var REDIRECT_URL = "oidc://callback";
```

5. [Android用設定] "android/app/build.gradle"ファイルに下記のカスタムスキーマが設定されていることを確認します。この場合、Androidの設定のため、"://callback"が付与されていません。
```
        manifestPlaceholders = [
            'appAuthRedirectScheme': 'oidc'
        ]
```
参考: https://github.com/openid/AppAuth-Android#capturing-the-authorization-redirect

6. [Android用設定] "android/app/src/main/AndroidManifest.xml"ファイルに下記のカスタムスキーマが設定されていることを確認します。この場合、Androidの設定のため、"://callback"が付与されていません。
```
        <activity android:name="net.openid.appauth.RedirectUriReceiverActivity">
          <intent-filter>
              <action android:name="android.intent.action.VIEW"/>
              <category android:name="android.intent.category.DEFAULT"/>
              <category android:name="android.intent.category.BROWSABLE"/>
              <data android:scheme="oidc"/>
          </intent-filter>
        </activity>
```
参考: https://github.com/openid/AppAuth-Android#capturing-the-authorization-redirect

7. [Android用設定] target APIが30以上の場合、"android/app/src/main/AndroidManifest.xml"ファイルに下記の記述が必要なので、この記述があることを確認します。
```
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.APP_BROWSER" />
        <data android:scheme="https" />
    </intent>
</queries>
```
参考: https://pub.dev/packages/flutter_appauth

8. [iOS用設定] "ios/Runner/Info.plist"ファイルに下記のカスタムスキーマが設定されていることを確認します。この場合、iOSの設定のため、"://callback"が付与されています。
```
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>oidc://callback</string>
            </array>
        </dict>
    </array>
```

9. Android端末を開発PCに認識させコンパイル&実行します。
```
$ flutter build ios
$ flutter devices
(認識された実行環境がリストされますのでそこにAndroid端末が含まれることを確認)
$ flutter run -d "(Android端末名)"
```

10. iPhoneを開発PCに認識させコンパイル&実行します。途中、XCodeを使ってApple Developerライセンスを認識させたり、CocoaPodをインストールするといった作業が必要です。
```
$ flutter build appbundle
$ flutter devices
(認識された実行環境がリストされますのでそこにiPhoneが含まれることを確認)
$ flutter run -d "(iPhone名)"
```

以上