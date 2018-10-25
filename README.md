# Dockerでフロントエンド開発環境を構築する

## Dockerって？

## Dockerを使うメリット

### OSに依存しない

こんなことが起こらなくなる（はず）

+ Macで動くのにWindowsで動かない🙉

+ OS Xアップデートしたら、開発環境が動かなくなった🙉

+ Node.jsのバージョンを案件によって切り替えなくちゃ🙉

### AWS CodeBuildとの連携

脱Jenkins！

詳しくは次回...


## 作ってみる

### 1. まず、Dockerをインストール

https://www.docker.com/

「Get Started」からダウンロードしてインストール

```
$ docker
```
で `docker` コマンド使えるようになればOK

### 2. 以下のようにファイルを置く

今回は、ビルドツールとして `Parcel` を使う

作業のためのディレクトリを切ります

```
$ mkdir docker-parcel-sample && cd docker-parcel-sample
```

3ファイルを全て同じ階層に配置します

```
// package.json
{
  "name": "docker-parcel-sample",
  "version": "1.0.0",
  "scripts": {
    "start": "parcel index.html"
  },
  "license": "ISC",
  "devDependencies": {
    "parcel-bundler": "^1.10.3"
  }
}
```

```
// index.html
<html>
<body>
  Hello!! This is Docker Parcel html.
  <script src="./index.js"></script>
</body>
</html>
```

```
// index.js
console.log('index.js');
```

### 3. まずローカルで確認

インストールして、起動

```
$ yarn
$ yarn start
```

http://localhost:1234/ にアクセスして `Hello!! This is Docker Parcel html.` と表示されればOK


### 4. `DockerFile` をつくる

同じ階層に以下を配置

```
// Dockerfile
# Install Node.js and npm
FROM node:8

# set workdir
WORKDIR /src

# Copy app files
COPY package.json /src/package.json
COPY index.html /src/index.html
COPY index.js /src/index.js

# Open port
EXPOSE 1234

# Install packages
RUN  yarn
```

### 5. Docker Build する

```
$ docker build -t docker-parcel-sample .
```

`-t` オプションで `docker-parcel-sample` という名前をつけた


```
Successfully built
```

と表示されればOK

### 6. Docker image を確認する

```
$ docker images
```

ビルド済みのイメージを確認できる

```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
docker-parcel-sample       latest              4eaf21cab20b        46 seconds ago      811MB
```

先ほどビルドしたイメージが一覧にあればOK

### 7. Docker Run する

```
$ docker run -p 1234:1234 -d docker-parcel-sample yarn start
```

`-p` `1234:1234` でコンテナ内のプライベートなポート（=1234）を公開ポート（=1234）に渡し

`-d` でデタッチド・モード＝バックグラウンドで起動する

`yarn start` コマンドをつけ、コンテナ内で `yarn start` が実行されます

http://localhost:1234/ にアクセスして `Hello!! This is Docker Parcel html.` と表示されればOK

コンテナ内で起動したParcelのローカルサーバーのポート `1234` と、ホストマシンのポート `1234` が繋がった（＝ポートフォワーディング）状態である

### 8. 起動しているコンテナを確認し、停止する

```
$ docker ps
```

起動しているコンテナが一覧表示される

```
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                    NAMES
932a5ba7cd12        docker-parcel-sample   "yarn start"        2 minutes ago       Up 2 minutes        0.0.0.0:1234->1234/tcp   boring_almeida
```

一度停止したいので

```
$ docker container stop [CONTAINER ID]
```

これで、http://localhost:1234/ にアクセスできなくなればOK

停止したコンテナ一覧は以下で確認できる

```
$ docker ps -a
```

先ほど作ったコンテナは削除したいので以下を実行

```
$ docker rm [CONTAINER ID]
```

もう一度、以下を実行し、コンテナ一覧から消えていればOK

```
$ docker ps -a
```


## LiveReload機能を使う


### docker-composeを使う

### ビルドする
