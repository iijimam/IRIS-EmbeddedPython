# InterSystem IRIS の Embedded Python お試し用テンプレート

この開発環境テンプレートは将来のInterSystems IRISリリースバージョン（2021.1）に含まれる予定の新機能 Enbedded Python をお試しいただくための環境を作成できます。

リリース前の為、実際の操作方法、環境準備方法がこのテンプレートと異なる場合もあります。予めご了承ください。


## コンテナ開始後のイメージ図

以下の図は、Docker for windows でコンテナを開始した時のイメージ図です。
（c:\docker　にいる状態で git clone した時の図です）
![環境イメージ図](/templateimage.png)



## 事前準備

お手元に、Git／VSCode／Docker のインストールをお願いします。


## コンテナ起動までの手順

詳細は、[docker-compose.yml](./docker-compose.yml) をご参照ください。

Git展開後、**./ は コンテナ内 /ISC ディレクトリをマウントしています。**
また、IRISの管理ポータルの起動に使用するWebサーバポートは 52773 が割り当てられています。
既に使用中ポートの場合は、[docker-compose.yml](./docker-compose.yml) の **15行目** を修正してご利用ください。

**≪62773に割り当てる例≫　- "62773:52773"**

```
git clone このGitのURL
```
cloneしたディレクトリに移動後、以下実行します。

```
$ docker-compose build
```
ビルド後、コンテナを開始します。
```
$ docker-compose up -d
```
コンテナを停止する方法は以下の通りです。
```
$ docker-compose stop
```
コンテナを破棄する方法は以下の通りです（コンテナを消去します）。
```
$ docker-compose down
```

##　Embedded Pythonを試す：barchat.pyを実行する迄の手順

コンテナビルド時に、VS2021.Alcoholテーブルとグローバル変数 ^Alcohol にサンプルデータを登録しています。
作成時に使用したコードを参照される場合は、[VS2021.Alcohol.cls](/src/VS2021/Alcohol.cls)の以下メソッドをご参照ください。


### (1) コンテナにログイン

コンテナ名は irispython で作成しています。以下のコマンドでコンテナにログインしてください。
```
docker exec -it irispython bash
```

### (2) pip3でライブラリをインストールした場合、インストールパスを確認してください。

例：コンテナビルド時に matplotlib を pip3 でインストールしています。確認方法は以下の通りです。

```
irisowner@8dbc1e05d1ad:/opt/irisapp$ pip3 show matplotlib
Name: matplotlib
Version: 3.0.3
Summary: Python plotting package
Home-page: http://matplotlib.org
Author: John D. Hunter, Michael Droettboom
Author-email: matplotlib-users@python.org
License: PSF
Location: /home/irisowner/.local/lib/python3.7/site-packages
Requires: kiwisolver, cycler, numpy, python-dateutil, pyparsing
irisowner@8dbc1e05d1ad:/opt/irisapp$
```

実行結果の **Location** のパスをコピーしておきます。

### (3) IRISにログインする

以下の実行でUSERネームスペースにログインします。
```
iris session IRIS
```

もし、オリジナルでネームスペースを作成している場合は、以下の方法で目的のネームスペースに移動できます（例　TRYネームスペースがある場合）。

```
iris session IRIS -U "TRY"
```

### (4) ObjectScript を利用して、sys.path パスを追加

以下のパスを追加します。
A) barchart.pyを動かすため、ソースコードがあるパス
B) barchat.pyが利用している matplotlib のインストールパス

Python の sys モジュールを操作するため、**%SYS.Python** クラスの **Import()** メソッドのインスタンスを作成します。

```
set sys=##class(%SYS.Python).Import("sys")
```

A) のソースがあるパスを **sys.path**　に追加します。

```
do sys.path.append("/ISC/src")
```

B) のインストールパスを **sys.path** に追加します。

```
do sys.path.append("/home/irisowner/.local/lib/python3.7/site-packages")
```

他モジュールを pip3 でインストールした場合も、インストールパスを **pip3 show モジュール名** で確認し、上記手順で sys.path　に追加してから実行してください。


### (5) barchat.pyを実行する（グローバルからDataFrameを作成して実行する）

[VS2021.Alcohol](/src/VS2021/Alcohol.cls) クラスの GetDFFromGlobal メソッドを使用してDataFrameを作成します。

実行例は以下の通りです。

1, DataFrameを作成する

```
set df=##class(VS2021.Alcohol).GetDFFromGlobal()
```

2, barchart.pyをインポートする

```
set bar=##class(%SYS.Python).Import("barchart")
```

3, buildGraph()を実行する

```
do bar.buildGraph(df,"/ISC/src/test1.png","Beer","LowMaltBeer")
```

出力結果は、VSCodeのワークスペース/src/test1.png　でご確認いただけます。


4, DataFrameの中身をprint()関数で参照する迄の手順

builtinsをインポートしてから実行します。
```
set b=##class(%SYS.Python).Import("builtins")
do b.print(df)
```


### (6) barchat.pyを実行する（SQLからDataFrameを作成して実行する）

[VS2021.Alcohol](/src/VS2021/Alcohol.cls) クラスの GetDF() メソッドを使用してDataFrameを作成します。

実行例は以下の通りです。

1, DataFrameを作成する

```
kill df
set df=##class(VS2021.Alcohol).GetDF()
```

2, barchart.pyをインポートする

```
set bar=##class(%SYS.Python).Import("barchart")
```

3, buildGraph()を実行する

```
do bar.buildGraph(df,"/ISC/src/test2.png","beer","lowmaltbeer")
```

出力結果は、VSCodeのワークスペース/src/test2.png　でご確認いただけます。


4, DataFrameの中身をprint()関数で参照する迄の手順

builtinsをインポートしてから実行します。
```
set b=##class(%SYS.Python).Import("builtins")
do b.print(df)
```



### (7) IRISをログアウトする

プロセス終了コマンド（hatl）を実行します。
```
halt
```


## メモ
### データ作成メソッド

テーブルデータ作成：　CreateTableData()
グローバルデータ作成：　CreateGlobalData()

実行例は以下の通り

(1) コンテナにログイン
```
docker exec -it irispython bash
```

(2) iris にログイン（USERネームスペースにログイン）
```
iris session IRIS
```

(3) メソッド実行
```
//テーブルデータ作成
do ##class(VS2021.Alcohol).CreateTableData()
//グローバルデータ作成
do ##class(VS2021.Alcohol).CreateGlobalData()
```

### データ作成ストアドプロシージャ

localhost:62773/csp/sys/UtilHome.csp　で管理ポータルを開きます。

管理ポータル > システムエクスプローラ > SQL > USERネームスペースを選択 > スキーマ：Alcohol を選択 >　「プロシージャ」を展開
ストアド名をクリックし、右画面の「プロシージャ実行」をクリックし、別画面に出る実行ボタンをクリックします。
    VS2021.Alcohol_CreateTableData()
    VS2021.Alcohol_CreateGlobalData()

