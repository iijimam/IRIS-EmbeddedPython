/// 年別アルコール別酒量
Class VS2021.Alcohol Extends %Persistent
{

/// 年別
Property Year As %String;

/// 酒
Property Sake As %Integer;

/// 合成清酒
Property SyntheticSake As %Integer;

/// 連続蒸留焼酎
Property ContinuousDistilledShochu As %Integer;

/// 単式蒸留焼酎
Property SingleDistilledShochu As %Integer;

/// ビール
Property Beer As %Integer;

Property LowMaltBeer As %Integer;

ClassMethod CreateTableData() [ SqlProc ]
{
    &sql(truncate table VS2021.Alcohol)

    &sql(insert into VS2021.Alcohol (Year,Sake,SyntheticSake,ContinuousDistilledShochu,SingleDistilledShochu,Beer,LowMaltBeer)
    VALUES(2019,68824,4412,64334,43611,493506,67278))
    &sql(insert into VS2021.Alcohol (Year,Sake,SyntheticSake,ContinuousDistilledShochu,SingleDistilledShochu,Beer,LowMaltBeer)
    VALUES(2018,67036,4065,62657,43300,506951,76385))
    &sql(insert into VS2021.Alcohol (Year,Sake,SyntheticSake,ContinuousDistilledShochu,SingleDistilledShochu,Beer,LowMaltBeer)
    VALUES(2017,71864,4281,65155,46830,507098,73520))
    &sql(insert into VS2021.Alcohol (Year,Sake,SyntheticSake,ContinuousDistilledShochu,SingleDistilledShochu,Beer,LowMaltBeer)
    VALUES(2016,69694,4486,65155,44494,493290,76404))
    &sql(insert into VS2021.Alcohol (Year,Sake,SyntheticSake,ContinuousDistilledShochu,SingleDistilledShochu,Beer,LowMaltBeer)
    VALUES(2015,68265,4670,64819,43844,484347,72687))
}

ClassMethod CreateGlobalData() [ SqlProc ]
{
    kill ^Alcohol("東京")
    //Sake,SyntheticSake,ContinuousDistilledShochu,SingleDistilledShochu,Beer,LowMaltBeer
    set ^Alcohol("東京",2019)="68824,4412,64334,43611,493506,67278"
    set ^Alcohol("東京",2018)="67036,4065,62657,43300,506951,76385"
    set ^Alcohol("東京",2017)="71864,4281,65155,46830,507098,73520"
    set ^Alcohol("東京",2016)="69694,4486,65155,44494,493290,76404"
    set ^Alcohol("東京",2015)="68265,4670,64819,43844,484347,72687"
}

ClassMethod GetDFFromGlobal() As %SYS.Python
{
    set builtins=##class(%SYS.Python).Import("builtins")
    set pd=##class(%SYS.Python).Import("pandas")
    set rows=builtins.list()
    set year=""
    for {
        //降順ループ
        set row=builtins.list()
        set data=""
        set year=$order(^Alcohol("東京",year),-1,data)
        if year="" { quit }
        //Sake,SyntheticSake,ContinuousDistilledShochu,SingleDistilledShochu,Beer,LowMaltBeer
        do row.append(year)  // 年の登録
        for i=1:1:$length(data,",") {
            set val=$piece(data,",",i)
            do row.append(val)
        }
        do rows.append(row)
    }
    set df=pd.DataFrame(rows)
    set collist=builtins.list()
    do collist.append("Year")
    do collist.append("Sake")
    do collist.append("SyntheticSake")
    do collist.append("ContinuousDistilledShochu")
    do collist.append("SingleDistilledShochu")
    do collist.append("Beer")
    do collist.append("LowMaltBeer")
    set df.columns=collist
    set df=df.astype("float")
    return df
}

ClassMethod GetDF() As %SYS.Python
{
    set stmt=##class(%SQL.Statement).%New()
    set st=stmt.%Prepare("select Year,Beer,LowMaltBeer from VS2021.Alcohol")
    set rset=stmt.%Execute()
    set provider=##class(%ML.AutoML.Provider).%New()
    set status=provider.%ResultSetToDataFrame(rset,.info,.df,.count)
    return df
}

Storage Default
{
<Data name="AlcoholDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Year</Value>
</Value>
<Value name="3">
<Value>Sake</Value>
</Value>
<Value name="4">
<Value>SyntheticSake</Value>
</Value>
<Value name="5">
<Value>ContinuousDistilledShochu</Value>
</Value>
<Value name="6">
<Value>SingleDistilledShochu</Value>
</Value>
<Value name="7">
<Value>Beer</Value>
</Value>
<Value name="8">
<Value>LowMaltBeer</Value>
</Value>
</Data>
<DataLocation>^VS2021.AlcoholD</DataLocation>
<DefaultData>AlcoholDefaultData</DefaultData>
<IdLocation>^VS2021.AlcoholD</IdLocation>
<IndexLocation>^VS2021.AlcoholI</IndexLocation>
<StreamLocation>^VS2021.AlcoholS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
