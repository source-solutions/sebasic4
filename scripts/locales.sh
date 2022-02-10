cd ../locales
for f in *.json; do  
    export fname=${f%}
    name=$(jq -r .NAME $fname)
    echo $name
done
