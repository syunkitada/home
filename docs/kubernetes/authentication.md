# Authentication

* ApiServerにはAuthentication(認証), Authorization(認可)の機能がある
    * ユーザの認証を行い、リソースへの認可を行う


## Authentication(認証)
* X509 Client Certs
    * SSL証明書のcommon nameでユーザを定義して認証する。
* Static Token File / Static Password File
    * ユーザの認証情報を書いたファイルをあらかじめ用意して認証する。
* Service Account Tokens
    * デフォルトで有効になっている認証方式。
    * Kubernetesで管理されるService accountのNameとTokenを使って認証する。
* OpenID Connect Tokens
    * OpenID providerに認証を委譲してTokenを使って認証する。
* Webhook Token Authentication
    * webhookで認証する。
* Authenticating Proxy
    * Proxyしたときに認証してproxy後のheaderに認証情報を付与する方式
* Keystone Password
    * OpenStackのKeystoneを使って認証


## Authorization(認可)
* AlwaysAllow / AlwaysDeny
    * 常に許可するか、常に拒否する
* ABAC
    * 許可policyを書いたファイルをあらかじめ用意してファイルに従い認可する
* RBAC
    * policyをkubectl createでetcdに定義しておき、これに従って認可する
* Webhook
    * webhookでやり取りした値で認可を行う


## 参考
https://kubernetes.io/docs/admin/authentication/
