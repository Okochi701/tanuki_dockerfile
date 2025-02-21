# ベースイメージ
FROM ubuntu:22.04

# 環境変数設定
ENV DEBIAN_FRONTEND=noninteractive
# XDG_RUNTIME_DIR を設定
ENV XDG_RUNTIME_DIR=/run/user/1000
#Linuxでscreenを使用する
ENV SHELL /bin/bash 



# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    ffmpeg \
    net-tools \
    sudo \
    xvfb \
    x11-apps \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

# 非 root ユーザーを作成
RUN useradd -m -s /bin/bash myuser && echo "myuser:password" | chpasswd \
    && usermod -aG sudo myuser

# XDG_RUNTIME_DIR を作成
RUN mkdir -p /run/user/1000 && chmod 700 /run/user/1000 \
    && chown myuser:myuser /run/user/1000 

# ワーキングディレクトリを設定（myuserのホームディレクトリ）
WORKDIR /home/myuser

# 必要なファイル・フォルダをコンテナにコピー
COPY Tanuki_move9.x86_64 ./Tanuki_move9.x86_64
COPY Project_tanuki_llm ./Project_tanuki_llm
COPY Tanuki_move9_Data ./Tanuki_move9_Data
COPY UnityPlayer.so ./UnityPlayer.so

# ファイルとフォルダの所有者を myuser に変更
RUN chown -R myuser:myuser /home/myuser/

# 実行ファイルに実行権限を付与
RUN chmod +x /home/myuser/Tanuki_move9.x86_64

# ユーザーを切り替え
USER myuser

# 仮想ディスプレイ (Xvfb) の起動
ENTRYPOINT ["bash", "-c", "Xvfb :0 -screen 0 1024x768x24 & exec /bin/bash"]

