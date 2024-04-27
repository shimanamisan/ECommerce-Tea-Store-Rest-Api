#!/bin/bash

# 実行時に必要な引数: ./postCreateCommand.sh 'Hn_Pgtech1234' './bin/Debug/' './'

# すべての出力をinstall.logにリダイレクト
exec &> /tmp/postCreateCommand.log

# .dacpac ファイルと .sql ファイルが見つかったかを追跡するためのフラグ
dacpac="false"
sqlfiles="false"

# SApassword, dacpath, sqlpath はスクリプト実行時の引数から取得される値で、
# SQL Server の SA ユーザのパスワード、DAC パッケージのパス、SQL スクリプトのパスを指定します。
SApassword=$1
dacpath=$2
sqlpath=$3

#  SQL コマンドをファイルに出力します。
echo "SELECT * FROM SYS.DATABASES" | dd of=testsqlconnection.sql

# 次に、60回試行するループを実行し、
# 各試行で sqlcmd を使って SQL Server に接続を試みます。
# 接続が成功すれば準備完了としてループを抜けます。
# 成功しない場合は1秒待って再試行します。
for i in {1..60};
do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SApassword -d master -i testsqlconnection.sql > /dev/null
    if [ $? -eq 0 ]
    then
        echo "SQL server ready"
        break
    else
        echo "Not ready yet..."
        sleep 1
    fi
done

# SQL 接続テスト用のファイル testsqlconnection.sql は使用後削除されます。
rm testsqlconnection.sql

# DAC パッケージの検出と処理:
# DAC パッケージの存在を $dacpath ディレクトリでチェックし、
# 存在すればそれぞれのファイルに対して sqlpackage コマンドを使ってデプロイを実行します。
# デプロイするデータベース名はファイル名から取得します。
for f in $dacpath/*
do
    if [ $f == $dacpath/*".dacpac" ]
    then
        dacpac="true"
        echo "Found dacpac $f"
    fi
done

# SQL ファイルの検出と実行:
# 同様に $sqlpath ディレクトリで .sql ファイルの存在をチェックし、見つかったファイルを sqlcmd を使って実行します。
for f in $sqlpath/*
do
    if [ $f == $sqlpath/*".sql" ]
    then
        sqlfiles="true"
        echo "Found SQL file $f"
    fi
done

if [ $sqlfiles == "true" ]
then
    for f in $sqlpath/*
    do
        if [ $f == $sqlpath/*".sql" ]
        then
            echo "Executing $f"
            /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SApassword -d master -i $f
        fi
    done
fi

if [ $dacpac == "true" ] 
then
    for f in $dacpath/*
    do
        if [ $f == $dacpath/*".dacpac" ]
        then
            dbname=$(basename $f ".dacpac")
            echo "Deploying dacpac $f"
            /opt/sqlpackage/sqlpackage /Action:Publish /SourceFile:$f /TargetServerName:localhost /TargetDatabaseName:$dbname /TargetUser:sa /TargetPassword:$SApassword
        fi
    done
fi