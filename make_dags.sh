for rule in all anvio assemble bin function taxonomy raw qc 
do
    bash launch.sh ./ ${rule} --dag | dot -Tsvg > dags/dag_${rule}.svg
    cairosvg dags/dag_${rule}.svg -o dags/dag_${rule}.pdf
done
