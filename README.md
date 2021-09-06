# Flutter+AppAuthプラグインを使ったOIDCログインサンプル

AndroidとiOS対応のネイティブアプリをワンコードで生成し、ホットリロードに対応したFlutterをベースにKeycloadなどのOIDC対応のIdPと連携してログインし、トークンを取得するサンプルアプリです。

ライブラリとしては [OpenID Foundation](https://openid.net/) がGithub上に開発している [OpenIDリポジトリ](https://github.com/openid) にある [Android版AppAuth](https://github.com/openid/AppAuth-Android) と [iOS版AppAuth](https://github.com/openid/AppAuth-iOS) をベースに開発された [Flutter版AppAuth](https://github.com/MaikuB/flutter_appauth) である [flutter_appauthプラグイン](https://pub.dev/packages/flutter_appauth) を利用して開発テスト工数削減と品質向上を図っています。

## 導入手順

1. [Keycloakのドキュメント](https://www.keycloak.org/docs/latest/server_admin/)を参照しながらkeycloakの環境を用意して、レルム作成と設定、一般ユーザの作成、クライアントの作成を行います。Webから作成した一般ユーザのアカウントにOIDCログインができるようにします。レルム管理者と一般ユーザのログインURLは下記の通りです。

- レルム管理者ログインURL: https://[Keycloakへのアドレス]/auth/admin/[レルム名]/console/
- 一般ユーザログインURL: https://[Keycloakへのアドレス]/auth/realms/[レルム名]/account

2. FlutterのAppAuthに設定する値をKeycloakにあわせて取得します。あとで使うのでどこかにメモしておきましょう。

- クライアント名(CLIENT_NAME)とクライアントシークレット(CLIENT_SECRET)
- ディスカバリURL(DISCOVERY_URL): https://[Keycloakへのアドレス]/auth/realms/apilabeyes/.well-known/openid-configuration の形式になります。
- リダイレクトURL(REDIRECT_URL): カスタムスキーマといい、ネイティブアプリがWebViewを開いて処理が終わったらWebViewをクローズしてネイティブアプリに操作を戻すトリガーに使います。"[パッケージ名]:/callback"という形式をとり、ここでは"com.example.demo2:/callback"としています。":/callback"部分はiOS用に設定した値でこれがないとiOSでWebViewはクロースしません。一方、Androidでは後述する「build.gradle」ファイルと「AndroidManifest.xml」ファイルにリダイレクトURLを設定しますが、":/callback"を除いた値"com.example.demo2"を設定します。

3. 本リポジトリをcloneして持ってきます。

```
$ git clone https://github.com/apilabeyes/oidc.git
```

4. 