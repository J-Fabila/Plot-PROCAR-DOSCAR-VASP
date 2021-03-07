orbitales=" s p d"
initial_atom=100
final_atom=110

for orbital in $orbitales
do
   for energia in $(seq -20 0.1 20)
#awk '{print $1}'  atomo8_orbital_d_up.dat  | sort -n | uniq | tr '\n' ' ')
   do
      rm sum_aux_up sum_aux_down
      for numero in $(seq $initial $final)
      do
         grep -- "$energia" atomo${numero}_orbital_${orbital}_up.dat >> sum_aux_up
         total_up=$(awk 'BEGIN {FS="\n"} ; {sum+=$1} END {print sum}' sum_aux_up)
         grep -- "$energia" atomo${numero}_orbital_${orbital}_down.dat >> sum_aux_down
         total_down=$(awk 'BEGIN {FS="\n"} ; {sum+=$1} END {print sum}' sum_aux_down)
      done
      echo $energia $total_up     >> group_${orbital}_${initial_atom}-${final_atom}_up.dat
      echo $energia $total_down   >> group_${orbital}_${initial_atom}-${final_atom}_down.dat
   done
done

