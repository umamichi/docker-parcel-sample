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

まず `package.json` をつくります

```
// package.json
{
  "name": "docker-parcel-sample",
  "version": "1.0.0",
  "scripts": {
    "start": "parcel src/index.html"
  },
  "license": "ISC",
  "devDependencies": {
    "parcel-bundler": "^1.10.3"
  }
}
```

`src` ディレクトリを作り、2ファイルを配置

```
// src/index.html
<html>
<body>
  Hello!! This is Docker Parcel html.
  <script src="./index.js"></script>
</body>
</html>
```

```
// src/index.js
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
WORKDIR /docker-app

# Copy app files
COPY package.json /docker-app/package.json
COPY src /docker-app/src

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

同時にビルドした、Dockerイメージも削除しておきましょう

`docker rmi` コマンドを使います

まず消したいイメージを見つけ、

```
$ docker images
```

以下コマンドで削除しておきましょう

```
$ docker rmi [IMAGE ID]
```



## LiveReload機能を使う

LiveReloadは `Websocket` によって行われるので、以下2つの対応をすれば良い

+ `Websocket` ポートをフォワーディングする

+ ホストマシンの `src` ディレクトリをコンテナ内の領域にマウントする


### 1. LiveReloadのポートを固定

ParcelのHMLのポートはランダムで割り当てられてしまうので、`8080` に固定にする

```
// package.json
...
"scripts": {
  "start": "parcel index.html --hmr-port 8080"
},
...
```

### 2. ポートフォワーディング

`8080`を追加

`src` ディレクトリをコンテナ内の領域に `COPY` する処理をコメントアウト

```
// Dockerfile

# Install Node.js and npm
FROM node:8

# set workdir
WORKDIR /docker-app

# Copy app files
COPY package.json /docker-app/package.json
# コメントアウト↓
# COPY src /docker-app/src

# Open port
EXPOSE 1234
# 追加↓
EXPOSE 8080

# Install packages
RUN  yarn
```

### 3. Docker Build する

さきほどと同じ

```
$ docker build -t docker-parcel-sample .
```


### 4. Docker Run する

```
$ docker run -p 1234:1234 -p 8080:8080 -d -v `pwd`/src:/docker-app/src docker-parcel-sample yarn start
```


`--p 1234:1234 -p 8080:8080` で複数のポートフォワーディング

`-v` で、ホストマシンの `src` ディレクトリをコンテナ内の `/docker-app/src` にマウントしている↓

```
-v `pwd`/src:/docker-app/src
```

**※Windowsでは `pwd` が使えないので、要調査**

http://localhost:1234 にアクセス

`src/index.html` を変更するとLiveReloadされることが確認できます


## docker-composeを使う

`docker-compose` を使ってみましょう

Build から Run までコマンド一つで簡単に実行できます

さきほど実行したような、長ったらしい `docker run` コマンドを実行する必要がなくなります

### 1. docker-composeをインストール

http://docs.docker.jp/compose/install.html

以下コマンドでバージョンが表示されればインストールはOK

```
$ docker-compose -v
```

### 2. docker-compose.ymlをつくる

`package.json` と同階層に以下を配置しましょう

```
// docker-compose.yml
version: '3'
services:
  docker-parcel-sample: # サービス名、自分で決めることができる
    build: ./             # Dockerfile のあるファイルの場所(git リポジトリのURL も指定可能)
    container_name: docker-parcel-sample  # コンテナ名。指定しなかった場合は Docker compose で勝手に決められる
    working_dir: /docker-app       # コンテナ内のワーキングディレクトリ
    ports:                         # ポートフォワーディング設定。docker run コマンドの-pに相当
     - 1234:1234                   # ローカルサーバー用
     - 8080:8080                   # websocket用
    volumes:                       # マウントするディレクトリ。docker run コマンドの-vに相当
     - $PWD/src:/docker-app/src   
    command: yarn start            # 実行コマンドを指定
```

### 3. docker-compose する

```
$ docker-compose up
```

BuildからRunまでこのコマンドで実行されます

http://localhost:1234 にて、LiveReloadが有効な開発環境が構築されました



