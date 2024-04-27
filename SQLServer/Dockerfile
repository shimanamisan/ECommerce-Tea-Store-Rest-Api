FROM mcr.microsoft.com/mssql/server:2022-latest

COPY installSQLtools.sh /installSQLtools.sh
COPY postCreateCommand.sh /postCreateCommand.sh
COPY setup.sql /setup.sql

USER root

# 必要なツールのインストール
RUN apt update && apt install -y curl gnupg unzip lsb-release && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/library-scripts && \
    chmod +x postCreateCommand.sh && \
    chmod +x installSQLtools.sh && \
    bash ./installSQLtools.sh