#!/bin/bash

# エラーが発生したらスクリプトを直ちに終了する
set -e

# すべての出力をinstall.logにリダイレクト
exec &> /tmp/install.log

echo "Installing mssql-tools"
# Microsoft の公開鍵の追加:
# このコマンドは Microsoft の公開鍵をダウンロードし、apt-key コマンドを使用してシステムの信頼できるキーに追加します。
# このキーは Microsoft のパッケージが正式なものであると認証するために必要です。
# エラーが発生した場合は、エラーメッセージが表示されます。
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT)

# リポジトリ情報の生成:
# ディストリビューション名 (DISTRO) とコードネーム (CODENAME) を取得して、これを使って Microsoft のパッケージリポジトリの URL を構築します。
# 以下のコマンドでディストリビューション名とコードネームを取得し、小文字に変換します。
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
# Microsoft のリポジトリ設定を保存
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-${DISTRO}-${CODENAME}-prod ${CODENAME} main" > /etc/apt/sources.list.d/microsoft.list
# 新しく追加したMicrosoftのリポジトリを反映するためにパッケージリストを更新
apt-get update
# Microsoft のエンドユーザーライセンス契約に同意することを表します
# -y オプションでインストール時の確認プロンプトを自動的に承認します。
ACCEPT_EULA=Y apt-get install -y unixodbc-dev msodbcsql17 libunwind8 mssql-tools

echo "Installing sqlpackage"
# Microsoft から sqlpackage ツールの zip アーカイブをダウンロードします。
curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux"
# ツールのためのディレクトリを作成
mkdir /opt/sqlpackage
# アーカイブファイルを解凍
unzip sqlpackage.zip -d /opt/sqlpackage 
# アーカイブファイルを削除
rm sqlpackage.zip
# ファイルに実行権限を付与する
chmod a+x /opt/sqlpackage/sqlpackage