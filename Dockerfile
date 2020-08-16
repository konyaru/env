FROM ruby:2.6.6-alpine3.12

ENV ROOT="/webapp"
ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

# ルート直下にwebappという名前で作業ディレクトリを作成（コンテナ内のアプリケーシ>ョンディレクトリ
RUN mkdir ${ROOT}
WORKDIR ${ROOT}

# リポジトリを更新し依存モジュールをインスト
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        gcc \
        g++ \
        libc-dev \
        libxml2-dev \
        linux-headers \
        make \
        nodejs \
        tzdata \
	git \
        yarn &&\
    apk add --update mariadb-dev && \
    apk add --virtual build-packs --no-cache \
        build-base \
        curl-dev && \
#    rm /usr/lib/mysqld* \
    rm /usr/bin/mysql*

# ホストのGemfileとGemfile.lockをコンテナにコピー
COPY Gemfile ${ROOT}
COPY Gemfile.lock ${ROOT}

# bundle installの実行
RUN bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib" && \
    bundle install
RUN apk del build-packs

# ホストのアプリケーションディレクトリ内をすべてコンテナに
COPY . ${ROOT}

# puma.sockを配置するディレクトリを作成
RUN mkdir -p tmp/sockets
