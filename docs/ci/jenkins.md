# Jenkins 2.0

pipeline標準装備
pipeline スクリプトに以下のように定義して、ビルドするとステージごとにビルドが走る
構文で、ビルドをパイプライン制御ができそう

また、スクリプトを直書きではなく、Githubのにスクリプトを置いておいてそこから取得して実行することもできる
参考: http://www.buildinsider.net/enterprise/jenkins/005


```
node {
  stage 'メッセージの表示' 
  sh 'echo Hello Pipeline.' 

  stage '日付の表示'
  sh 'date'
}
```
