set terminal pngcairo size 1024,768 enhanced font 'Helvetica, 20'
set output 'prueba.png'
set title "Au_{2}Ir_{3}/TiO_{2}(101)" font "Helvetica, 25"
set xlabel 'E-E_F (eV)'  font "Helvetica, 20"
set ylabel 'PDOS (States/eV)' font "Helvetica, 20"
set xtics font "Helvetica, 20"
set yzeroaxis lt -1 lw 3
#set noytics

set xrange [-4:2]

#set style fill transparent solid 0.55 noborder
plot  "sustrato_up.dat" u 1:2 with lines lt rgb  "blue" dt 2 title "TiO_2", "sustrato_down.dat" u 1:2  with lines lt rgb  "blue" dt 2 notitle,  "group_d_108-113_up.dat" with lines lt rgb "red" dt 3 title "Au_2Ir3(d)",  "group_s_108-113_up.dat" with lines lt rgb "orange" dt 4 notitle,  "group_d_108-113_down.dat" with lines lt rgb "red" dt 3 notitle,  "group_s_108-113_down.dat" with lines lt rgb "orange" dt 4 title "Au_2Ir_3(s)", "total_up.dat" u 1:2 with lines lt rgb  "black" dt 1 title "Total", "total_down.dat" u 1:2  with lines lt rgb  "black" dt 1 notitle,

#"cluster_up.dat" u 1:2 with lines lt rgb  "green" title "Cluster", "cluster_down.dat" u 1:2  with lines lt rgb  "green" notitle,  

