########################################################################
############################### INPUT ##################################
########################################################################


#***************************** SISTEMA ********************************#

                #Se puede proporcionar el archivo DOSCAR y entonces este
                #script lo leerá de ahi, en ese caso se deja   Efermi*=0
# energia=$(grep " # occ.  0.00000" PROCAR | head -1 | awk '{print $5}')

EfermiUp=0
EfermiDown=0
Draw_all=false  #This option will draw every single orbital of each atom
split=true      #This option willl split the DOS into customized regions
group_by=true
#****************************** SPLIT *********************************#

number_divisions=1                 #Number of "regions" to split the DOS
                               # NOTE: Add as many divisions as you want

                     # NOTE: number of marks shall be number_divisions+1
m_1=1             #Number of atom, which mark the initial bound to split
m_2=113
#m_2=108                 #Number of atom, which mark the end of first region
                     # end of second one
#m_3=113

#m_4=

#**************************** GROUP BY *******************************#
orbitales=" s p d"
initial_atom=108
final_atom=113

#***************************** GNUPLOT ********************************#

Title="Au_{1}Ir_{4}/TiO_{2}(101)"               #Gnuplot generará un .png llamado 'Title.png'
                              #La imagen generada tendrá el mismo título
AutomaticRange=false             #Utiliza el rango automático de gnuplot
                        #Si 'true' entonces se  inhabilita lo siguiente:
xmin=-7           #Cota mínima del rango en X de la gráfica que generará
xmax=7            #Cota máxima del rango en X de la gráfica que generará
desv=0.2       #Ancho de las campanas gaussianas alrededor de cada punto
NombreScript=Script_gplot    #Se genera un script llamado 'NombreScript'
          #ése es modificable. Si la gráfica no es de agrado simplemente
                       #se   cambian los parámetros en él escritos, pero
   #ya no es necesario volver a correr el presente programa. Sino que se
     #ejecuta '$~ gnuplot NombreScript' con 'NombreScript' ya modificado
                 #generando un nuevo .png con los parámetros modificados


#########################################################################
############################ TERMINA INPUT ##############################
#########################################################################
echo " Reading variables"
echo " "
echo "Obtaining atomic species"
echo " "
###### Se obtienen los elementos ##########
to_xyz POSCAR > poscar.xyz
Nat=$(head -1 poscar.xyz )
tail -$Nat poscar.xyz | awk '{print $1}' > elementos

echo "Spliting PROCAR FILE into spin up/down"
echo " "
##### Divide el archivo en 2: unopara spinup y otro para down
nl=$(echo $(wc -l PROCAR | awk '{print $1}')/2 | bc)
tail -$nl PROCAR > procar.down
head -$nl PROCAR > procar.up
echo "Obtaining energies"
echo " "
##### Obtiene las energias para ambos espines
grep  "energy" procar.up  | awk '{print $5}' > energias.up  #PROCAR-->$1
grep  "energy" procar.down  | awk '{print $5}' > energias.down  #PROCAR-->$1
# Obtiene la energia de Fermi
echo "Reading Fermi energies (up/down)"
echo " "
EfermiUp=$(grep "# occ.  0.000" procar.up  | head -1 | awk '{print $5}')
EfermiDown=$(grep "# occ.  0.000" procar.down  | head -1 | awk '{print $5}')
echo " Fermi Up: $EfermiUp ; Fermi Down: $EfermiDown"
echo " "
#Agrega la energía de Fermi
if [ $split = "true" ]
then
   cp energias.up energias_up
   cp energias.down energias_down
fi
echo "Shifting to Fermi level"
echo " "
########################## DEJARLO PAL FINAL
if [ $Draw_all = "true" ] | [ $group_by = "true" ]
then
   echo "awk '{print \$1-($EfermiUp)}' energias.up " | bash > energias_up
   echo "awk '{print \$1-($EfermiDown)}' energias.down " | bash > energias_down
fi

##### Se generan todos los archivos individuales listos para graficar ###
echo "Spliting files to atoms/orbitals/spin"
echo " "
for ((i=1;i<$(($Nat+1));i++))
do
   echo "Atom  $i ..."
   # Desglosa los archivos por átomo por orbital por espín
   grep -A $Nat "ion " procar.up  | grep " $i " | awk '{print $2}' > atomo${i}_orbitals_up.aux
   grep -A $Nat "ion " procar.up  | grep " $i " | awk '{print $3}' > atomo${i}_orbitalp_up.aux
   grep -A $Nat "ion " procar.up  | grep " $i " | awk '{print $4}' > atomo${i}_orbitald_up.aux
   grep -A $Nat "ion " procar.up  | grep " $i " | awk '{print $5}' > atomo${i}_total_up.aux

   grep -A $Nat "ion " procar.down  | grep " $i " | awk '{print $2}' > atomo${i}_orbitals_down.aux
   grep -A $Nat "ion " procar.down  | grep " $i " | awk '{print $3}' > atomo${i}_orbitalp_down.aux
   grep -A $Nat "ion " procar.down  | grep " $i " | awk '{print $4}' > atomo${i}_orbitald_down.aux
   grep -A $Nat "ion " procar.down  | grep " $i " | awk '{print $5}' > atomo${i}_total_down.aux

   # Crea los archivos  correspondientes
   echo "awk '{print \$1}' atomo${i}_orbitals_up.aux " | bash > atomo${i}_orbital_s_up
   echo "awk '{print (-1.0)*\$1}' atomo${i}_orbitals_down.aux " | bash > atomo${i}_orbital_s_down

   echo "awk '{print \$1}' atomo${i}_orbitalp_up.aux " | bash > atomo${i}_orbital_p_up
   echo "awk '{print (-1.0)*\$1}' atomo${i}_orbitalp_down.aux " | bash > atomo${i}_orbital_p_down

   echo "awk '{print \$1}' atomo${i}_orbitald_up.aux " | bash > atomo${i}_orbital_d_up
   echo "awk '{print (-1.0)*\$1}' atomo${i}_orbitald_down.aux " | bash > atomo${i}_orbital_d_down

   echo "awk '{print \$1}' atomo${i}_total_up.aux " | bash > atomo${i}_total_up
   echo "awk '{print (-1.0)*\$1}' atomo${i}_total_down.aux " | bash > atomo${i}_total_down

   echo "   Done! "
########################## ACA HABRA QUE AGREGAR UN FOR QUE ITERE SOBRE CADA TIPO DE ATOMO Y SUME TODO
   if [ $split = "true" ]
   then
      paste energias_up atomo${i}_total_up > atomo${i}_total_up.dat
      paste energias_down atomo${i}_total_down > atomo${i}_total_down.dat
   fi
########################## DEJARLO PAL FINAL
   if [ $Draw_all = "true" ] | [ $group_by = "true" ]
   then   # Junta la información con el tipo de atomo y las energías, genera las gaussianas
      paste energias_up atomo${i}_orbital_s_up > atomo${i}_orbital_s_up.dat
      ./gaussiana atomo${i}_orbital_s_up.dat $(wc -l atomo${i}_orbital_s_up.dat | awk '{print $1}') $desv
#   sort  -nk1 salida.tmp  > atomo${i}_orbital_s_up.dat
      cat salida.tmp  > atomo${i}_orbital_s_up.dat
      rm salida.tmp

      paste energias_down atomo${i}_orbital_s_down > atomo${i}_orbital_s_down.dat
      ./gaussiana atomo${i}_orbital_s_down.dat $(wc -l atomo${i}_orbital_s_down.dat | awk '{print $1}') $desv
#   sort  -nk1 salida.tmp  > atomo${i}_orbital_s_down.dat
      cat  salida.tmp  > atomo${i}_orbital_s_down.dat
      rm salida.tmp

      paste energias_up atomo${i}_orbital_p_up > atomo${i}_orbital_p_up.dat
      ./gaussiana atomo${i}_orbital_p_up.dat $(wc -l atomo${i}_orbital_p_up.dat | awk '{print $1}') $desv
#   sort  -nk1 salida.tmp  > atomo${i}_orbital_p_up.dat
      cat salida.tmp  > atomo${i}_orbital_p_up.dat
      rm salida.tmp


      paste energias_down  atomo${i}_orbital_p_down > atomo${i}_orbital_p_down.dat
      ./gaussiana atomo${i}_orbital_p_down.dat $(wc -l atomo${i}_orbital_p_down.dat | awk '{print $1}') $desv
#   sort  -nk1 salida.tmp  > atomo${i}_orbital_p_down.dat
      cat salida.tmp  > atomo${i}_orbital_p_down.dat
      rm salida.tmp

      paste energias_up atomo${i}_orbital_d_up > atomo${i}_orbital_d_up.dat
      ./gaussiana atomo${i}_orbital_d_up.dat $(wc -l atomo${i}_orbital_d_up.dat | awk '{print $1}') $desv
   #   sort  -nk1 salida.tmp  > atomo${i}_orbital_d_up.dat
      cat salida.tmp  > atomo${i}_orbital_d_up.dat
      rm salida.tmp

      paste energias_down atomo${i}_orbital_d_down > atomo${i}_orbital_d_down.dat
      ./gaussiana atomo${i}_orbital_d_down.dat  $(wc -l atomo${i}_orbital_d_down.dat | awk '{print $1}') $desv
   #   sort  -nk1 salida.tmp  > atomo${i}_orbital_d_down.dat
      cat salida.tmp  > atomo${i}_orbital_d_down.dat
      rm salida.tmp
   fi
   # Elimina archivos residuales (auxiliares)
   rm atomo${i}_orbitals_up.aux atomo${i}_orbital_s_up
   rm atomo${i}_orbitals_down.aux atomo${i}_orbital_s_down
   rm atomo${i}_orbitalp_up.aux atomo${i}_orbital_p_up
   rm atomo${i}_orbitalp_down.aux atomo${i}_orbital_p_down
   rm atomo${i}_orbitald_up.aux atomo${i}_orbital_d_up
   rm atomo${i}_orbitald_down.aux atomo${i}_orbital_d_down
   rm atomo${i}_total_up.aux atomo${i}_total_up
   rm atomo${i}_total_down.aux atomo${i}_total_down
done
echo "Grouping and summing up energies ..."
for ((division=1;division<$(($number_divisions+1));division++))
do
   echo "Region / Division $division ..."
   lower=$(echo $((m_${division})))
   division=$(($division+1))
   upper=$(echo $((m_${division})))
   division=$(($division-1))
   for  energia in $(cat energias_up | tr '\n'  ' ' )
   do
      echo "---> Band $energia (Spin up)"
      rm sum_aux_file_up 2> /dev/null
      #for ((ion=mark_($division);ion<mark_($division+1);ion++))
      for ((ion=$(echo $lower) ; ion < $(echo $upper) ; ion++))
      do
         echo "   ---> Ion $ion"
         grep -- $energia  atomo${ion}_total_up.dat | awk '{print $2}' >> sum_aux_file_up
      done
      sum_up=$(cat sum_aux_file_up | tr '\n' '+')
      total_up=$(echo "${sum_up::-1}" | bc -l)
      echo $energia $total_up   >> conjunto_${division}_up
      echo $energia $total_up   >> total_up

   done
   for  energia in $(cat energias_down | tr '\n'  ' ' )
   do
      echo "---> Band $energia (Spin down)"
      rm sum_aux_file_down 2> /dev/null
      #for ((ion=mark_($division);ion<mark_($division+1);ion++))
      for ((ion=$(echo $lower) ; ion < $(echo $upper) ; ion++))
      do
         echo "   ---> Ion $ion"
         grep -- $energia  atomo${ion}_total_down.dat | awk '{print $2}' >> sum_aux_file_down
      done
      sum_down=$(cat sum_aux_file_down | tr '\n' '+')
      total_down=$(echo "${sum_down::-1}" | bc -l)
      echo $energia $total_down >> conjunto_${division}_down
      echo $energia $total_down   >> total_down
   done
echo " Done!"
##############################################################
####################### Verificado
   ./gaussiana conjunto_${division}_down $(wc -l conjunto_${division}_down | awk '{print $1}') $desv
   cat salida.tmp  > conjunto_${division}_down
   rm salida.tmp
   echo "awk '{print \$1-($EfermiDown)}' conjunto_${division}_down " | bash > energias_shift_down
   awk '{print $2}' conjunto_${division}_down > estados_down
   paste energias_shift_down estados_down > conjunto_${division}_down

   ./gaussiana conjunto_${division}_up $(wc -l conjunto_${division}_up | awk '{print $1}') $desv
   cat salida.tmp  > conjunto_${division}_up
   rm salida.tmp
   echo "awk '{print \$1-($EfermiUp)}' conjunto_${division}_up " | bash > energias_shift_up
   awk '{print $2}' conjunto_${division}_up > estados_up
   paste energias_shift_up estados_up > conjunto_${division}_up
echo "Summing gaussians"
#########################################################
############## VERIFICAO ################################
#################################################################################
#  DESPUÉS DE ESTO DEBES AGREGAR OOOOTROO LOOOP QUE TE SUME LAS GAUSSIANAS
   for  energia in $(cat conjunto_${division}_up   | sort -k1n | awk '{print $1}' | uniq | tr '\n' ' ')
   do
      echo "Energia: $energia ; Spin: Up"
      grep -- "$energia" conjunto_${division}_up | awk '{print $2}' > sum_up
      total_up=$(awk 'BEGIN {FS="\n"} ; {sum+=$1} END {print sum}' sum_up)
      echo "totalup $total_up"
      echo $energia $total_up   >> conjunto_${division}_up.dat
   done
   for  energia in $(cat conjunto_${division}_down | sort -k1n | awk '{print $1}' | uniq | tr '\n' ' ')
   do
      echo "Energia: $energia ; Spin: Down"
      grep -- "$energia" conjunto_${division}_down | awk '{print $2}' > sum_down
      total_down=$(awk 'BEGIN {FS="\n"} ; {sum+=$1} END {print sum}' sum_down)
      echo "totaldown $total_down"
      echo $energia $total_down   >> conjunto_${division}_down.dat
   done
done
echo "done"

if [ $group_by = "true" ]
then
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
fi
#***********************************************************************#
#                      ESCRIBE SCRIPTS PARA GNUPLOT                     #
#***********************************************************************#

echo "Se grafica lo siguiente con los colores indicados "
echo "Atomo  Orbital  Color"

echo "set terminal pngcairo size 1024,768 enhanced font 'Helvetica, 20'
set output '$Title.png'" > $NombreScript
echo -n "set title \"" >> $NombreScript
echo -n "$Title" >> $NombreScript
echo "\" font \"Helvetica, 25\"">> $NombreScript
echo "set xlabel 'E-E_f (eV)'  font \"Helvetica, 20\"
set ylabel 'PDOS (Estados/eV)' font \"Helvetica, 20\"
set xtics font \"Helvetica, 20\"
set yzeroaxis lt -1 lw 3
set noytics " >> $NombreScript

if [ $AutomaticRange = false ]
then
echo "
set xrange [$xmin:$xmax]
">> $NombreScript
fi

echo "set style fill transparent solid 0.55 noborder ">> $NombreScript
echo -n "plot  " >> $NombreScript

####################################################################################
####################################################################################
if [ $Draw_all = "true" ]
then
for ((l=1;l<$(($Nat+1));l++))
do
   tipo=$( head -$l elementos | tail -1 )
   graf_s=$(grep -A $Nat "Cartesian" POSCAR  | tail -$Nat | head -$l | tail -1 | awk '{print $4}')
   if [ $graf_s = "T" ]
   then
      j=_s
      fileup=$(ls atomo${l}_orbital*${j}_up.dat)
      filedown=$(ls atomo${l}_orbital*${j}_down.dat)
      color=$(grep "${tipo}_" colores | grep "$j" | awk '{print $2}')
      echo -n "\"${fileup}\" u 1:2 w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"${color}\" notitle, " >> $NombreScript
      echo -n "\"${filedown}\" u 1:2  w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"$color\" notitle, " >> $NombreScript
      echo  "$l (${tipo})    $(echo $j | cut -d "_" -f 2 )   $color "
   fi
   graf_p=$(grep -A $Nat "Cartesian" POSCAR  | tail -$Nat | head -$l | tail -1 | awk '{print $5}')
   if [ $graf_p = "T" ]
   then
      j=_p
      fileup=$(ls atomo${l}_orbital*${j}_up.dat)
      filedown=$(ls atomo${l}_orbital*${j}_down.dat)
      color=$(grep "${tipo}_" colores | grep "$j" | awk '{print $2}')
      echo -n "\"${fileup}\" u 1:2 w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"${color}\" notitle, " >> $NombreScript
      echo -n "\"${filedown}\" u 1:2  w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"$color\" notitle, " >> $NombreScript
      echo  "$l (${tipo})    $(echo $j | cut -d "_" -f 2 )   $color "

   fi
   graf_d=$(grep -A $Nat "Cartesian" POSCAR  | tail -$Nat | head -$l | tail -1 | awk '{print $6}')
   if [ $graf_d = "T" ]
   then
      j=_d
      fileup=$(ls atomo${l}_orbital*${j}_up.dat)
      filedown=$(ls atomo${l}_orbital*${j}_down.dat)
      color=$(grep "${tipo}_" colores | grep "$j" | awk '{print $2}')
      echo -n "\"${fileup}\" u 1:2 w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"${color}\" notitle, " >> $NombreScript
      echo -n "\"${filedown}\" u 1:2  w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"$color\" notitle, " >> $NombreScript
      echo  "$l (${tipo})    $(echo $j | cut -d "_" -f 2 )   $color "

   fi

done 2>/dev/null
#echo $EfermiUp
fi
####################################################################################
####################################################################################

####################################################################################
####################################################################################
if [ $split = "true" ]
then
echo "split = $split $number_divisions"
   for ((division=1;division<$(($number_divisions+1));division++))
   do
echo "entering ploting loop"
      fileup=$(ls conjunto_${division}_up.dat)
      filedown=$(ls conjunto_${division}_down.dat)
      color=$(grep "region_${division}" colores | awk '{print $2}')
      echo -n "\"${fileup}\" u 1:2 w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"${color}\" notitle, " >> $NombreScript
      echo -n "\"${filedown}\" u 1:2  w filledcurve y=0 lt rgb " >> $NombreScript
      echo -n " \"$color\" notitle, " >> $NombreScript
      echo  "$l (${tipo})    $(echo $j | cut -d "_" -f 2 )   $color "
#      echo -n "\"${fileup}\" u 1:2 w filledcurve y=0 lt rgb " >> $NombreScript
done
fi
####################################################################################
####################################################################################


gnuplot $NombreScript
rm energias_up energias_down elementos procar.down procar.up poscar.xyz energias.up energias.down
