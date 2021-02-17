#イメージのタグはこちら（https://hub.docker.com/_/intersystems-iris-data-platform）でご確認ください
ARG IMAGE=store/intersystems/iris-ml-community:2020.3.0.304.0

FROM $IMAGE

USER root

###########################################
##### Install Python

RUN apt-get update
RUN apt-get -y install locales && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ JST-9
ENV TERM xterm

RUN apt-get install python3 -y && \
  apt-get install python3.7 -y && \
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1 && \
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2 && \
  update-alternatives --set python3 /usr/bin/python3.7 && \
  apt-get update && \
  apt-get -y upgrade  && \
  apt-get -y install python3-pip && \
  export PYTHONHOME=/usr/local/lib/python3.7

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

#ファイルコピー
COPY iris.script iris.script
COPY src src

# iris.scriptに記載された内容を実行
RUN iris start IRIS \
	&& iris session IRIS < iris.script \
  && iris stop IRIS quietly

# barchat.pyで使用する matplotlibをインストール
RUN pip3 install matplotlib==3.0.3