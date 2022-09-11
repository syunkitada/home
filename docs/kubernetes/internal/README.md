# kubernetes

- 参考になりそうなもの
  - https://k8sinternal.connpass.com/
- コーディング規約
  - https://github.com/kubernetes/community/blob/master/contributors/guide/coding-conventions.md
- API の規約
  - https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md
    - k8s API 自体の規約なのであまり汎用的な話ではない（参考にならない）
  - https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api_changes.md
    - API の設計や、ジェネレータなどが参考になる
- フロントの API は OpenAPI を使ってるが、内部通信は GRPC を使ってる
  - https://medium.com/analytics-vidhya/grpc-vs-rest-performance-comparison-1fe5fb14a01c
  - GRPC のほうがパフォーマンスがよい(json はデコードのコストが高い)
    - json でも codecgen 使うともう少しましになるかも？
- スケーリングについて
  - コントローラはリーダエレクションで常に一つ
    - この処理能力が限界値になる
  - シャーディングして複数コントローラでスケールするみたいなことはできない
- 用語メモ
  - virtual kubelet
  - informer
  - kubebuilder

## ディレクトリ構成

- cmd
  - 各種コンポーネントのエントリポイントのコードが配置されてます
- pkg
  - 各種コンポーネントのメインコードが配置されてます
- staging/src/k8s.io
  - 汎用的なコード、ライブラリ群などが置いてある
  - stating/src/k8s.io 内のコードは、github のプロジェクトルートにも同期されており、それらを単体で利用することもできる
    - 例えば、Kubernetes API を利用するためのクライアントライブラリは以下のように、実態は stating/src/k8s.io で管理されるが、それ単体でも公開されていて単体でも利用できる
      - https://github.com/kubernetes/kubernetes/tree/master/staging/src/k8s.io/client-go
      - https://github.com/kubernetes/client-go

## ジェネレータまわりのメモ

- 基本的に go ファイルをベースに、コードを生成している
- ツール類
  - https://github.com/kubernetes/gengo
    - go ファイルをベースにコード生成するためのツール?
  - https://github.com/kubernetes/code-generator
    - ジェネレータの本体？
    - この内部でも gengo を使っている
    - このジェネレータを使ってる場合もあれば、そうでない場合もある?
  - defaulter-gen
  - deepcopy-gen
  - conversion-gen
  - openapi-gen
  - go-to-protobuf
  - client-gen
  - lister-gen
  - informer-gen
  - codecgen

make update で全コードを自動生成できる

```build/root/Makefile
161 update: generated_files
162     CALLED_FROM_MAIN_MAKEFILE=1 hack/make-rules/update.sh
```

update.sh の中では、以下のスクリプトを呼んでるだけなので、これらのスクリプトを読み進めるとよさそう

```hack/make-rules/update.sh
46 BASH_TARGETS="
47     update-generated-protobuf
48     update-codegen
49     update-generated-runtime
50     update-generated-device-plugin
51     update-generated-api-compatibility-data
52     update-generated-docs
53     update-generated-swagger-docs
54     update-openapi-spec
55     update-gofmt"
```

update-openapi-spec.sh の場合は、kube-apiserver を起動して curl で swagger.json を生成していた

```
hack/update-openapi-spec.sh
```

```
102 curl -w "\n" -kfsS -H 'Authorization: Bearer dummy_token' "https://${API_HOST}:${API_PORT}/openapi/v2" | jq -S '.info.version="unversioned"' > "${OPENAPI_ROOT_DIR}/swagger.json"
...
116 curl -w "\n" -kfsS -H 'Authorization: Bearer dummy_token' "https://${API_HOST}:${API_PORT}/openapi/v3/{$group}" | jq -S '.info.version="unversioned"' > "$OPENAPI_PATH"
```
