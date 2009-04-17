#for n1 in "De Morgan" "D'Morgun" "D'Morgun" "Demorgyn" "De Murgen" "Dy Moregan" "Dy Murgan" "Da Murgan" "Da Morgan" "Da Myrgn"; do
for n1 in "De Morgan"; do
  for n2 in "De Morgan" "D'Morgun" "D'Morgun" "Demorgyn" "De Murgen" "Dy Moregan" "Dy Murgan" "Da Murgan" "Da Morgan" "Da Myrgn"; do
    echo "$n1 vs $n2 `bash edit-distance.sh "$n1" "$n2"`";
  done;
done;
