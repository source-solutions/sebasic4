cd locales
for f in *.json; do  
    export jname=${f%}
    name=$(jq -r .NAME $jname)
    echo Generating $name
    fname=$(jq -r .FILENAME $jname)
    iconv=$(jq -r .ICONV $jname)
    scroll=$(jq -r .SCROLL $jname)
    error=$(jq -r .ERROR $jname)
    ready=$(jq -r .READY $jname)
    ok=$(jq -r .OK $jname)
    break=$(jq -r .BREAK $jname)
    for=$(jq -r .FOR $jname)
    synatx=$(jq -r .SYNTAX $jname)
    gosub=$(jq -r .GOSUB $jname)
    data=$(jq -r .DATA $jname)
    call=$(jq -r .CALL $jname)
    overflow=$(jq -r .OVERFLOW $jname)
    memory=$(jq -r .MEMORY $jname)
    line=$(jq -r .LINE $jname)
    subscript=$(jq -r .SUBSCRIPT $jname)
    variable=$(jq -r .VARIABLE $jname)
    address=$(jq -r .ADDRESS $jname)
    statement=$(jq -r .STATEMENT $jname)
    type=$(jq -r .TYPE $jname)
    screen=$(jq -r .SCREEN $jname)
    device=$(jq -r .DEVICE $jname)
    stream=$(jq -r .STREAM $jname)
    channel=$(jq -r .CHANNEL $jname)
    function=$(jq -r .FUNCTION $jname)
    buffer=$(jq -r .BUFFER $jname)
    next=$(jq -r .NEXT $jname)
    wend=$(jq -r .WEND $jname)
    while=$(jq -r .WHILE $jname)
    file=$(jq -r .FILE $jname)
    input=$(jq -r .INPUT $jname)
    path=$(jq -r .PATH $jname)
    echo $scroll"_"$error"_"$ready"_"$ok"_"$break"_"$for"_"$synatx"_"$gosub"_"$data"_"$call"_"$overflow"_"$memory"_"$line"_"$subscript"_"$variable"_"$address"_"$statement"_"$type"_"$screen"_"$device"_"$stream"_"$channel"_"$function"_"$buffer"_"$next"_"$wend"_"$while"_"$file"_"$input"_"$path"________________________________________________________________________________________________________________________________________" > TEMP.LN
    iconv -f UTF8 -t $iconv TEMP.LN > $fname
    head -c 608 $fname > TEMP.LN
    mv TEMP.LN $fname
    perl -pi -e 's/_/\0/g' $fname
    mv $fname ../ChloeVM.app/Contents/Resources/chloehd/SYSTEM/LANGUAGE.S/$fname
done
