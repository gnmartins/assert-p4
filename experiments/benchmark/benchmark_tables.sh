cwd=$(pwd)
now=$(date +"%T")
mkdir $now
cd $now
p4benchmark --feature pipeline --tables $1 --table-size 32

/home/$USER/p4c/build/p4test --pp out.p4 --p4-14 output/main.p4
/home/$USER/p4c/build/p4c-bm2-ss out.p4 --toJSON file.json


if [ $2 = "sefl" ]; then
  python /home/$USER/Desktop/assert-p4/src/P4_to_SEFL.py file.json
  sudo cp SEFLRunner.scala /home/$USER/Desktop/Symnet/src/main/scala/org/change/v2/runners/experiments/SEFLRunner.scala
  STARTTIME=$(date +%s)
  cd /home/$USER/Desktop/Symnet
  /usr/bin/time -o /home/$USER/Desktop/assert-p4/experiments/benchmark/results/sefl/$1_mem.txt sudo sbt sample -mem 3000 -J-Xmx3g
else
  python /home/$USER/Desktop/assert-p4/src/P4_to_C.py file.json > benchmark_model.c
  llvm-gcc -I ../../include -emit-llvm -c -g benchmark_model.c
  STARTTIME=$(date +%s)
  /usr/bin/time -o /home/$USER/Desktop/assert-p4/experiments/benchmark/results/c/$1_mem.txt klee --search=dfs --warnings-only-to-file --no-output benchmark_model.o
fi

ENDTIME=$(date +%s)
ELAPSED_TIME=$(($ENDTIME - $STARTTIME))

cd $cwd
echo $1 $ELAPSED_TIME >> result_tables.txt

