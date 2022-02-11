cd ../locales
for f in *.json; do  
    export jname=${f%}
    name=$(jq -r .NAME $jname)
    echo Generating $name
    fname=$(jq -r .FILENAME $jname)
    iconv=$(jq -r .ICONV $jname)
    scroll=$(jq -r .SCROLL < $jname)
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
    echo $scroll"\0"$error"\0"$ready"\0"$ok"\0"$break"\0"$for"\0"$synatx"\0"$gosub"\0"$data"\0"$call"\0"$overflow"\0"$memory"\0"$line"\0"$subscript"\0"$variable"\0"$address"\0"$statement"\0"$type"\0"$screen"\0"$device"\0"$stream"\0"$channel"\0"$function"\0"$buffer"\0"$next"\0"$wend"\0"$while"\0"$file"\0"$input"\0"$path"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0" > TEMP.LN
    perl -pi -e 's/\\0/\0/g' $fname
    iconv -f UTF8 -t $iconv TEMP.LN > $fname
    head -c 608 $fname > TEMP.LN
    mv TEMP.LN $fname
    perl -pi -e 's/_/\0/g' $fname
done
