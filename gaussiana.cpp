#include<iostream>
#include<fstream>
#include <stdio.h>
#include  <string>
#include   <cmath>

using namespace std;
double maxi, desv=0.1, pos;
double e=2.71828182;
int i;
int j;
int Nat;
void crear_gaussiana(double pos, double maxi, double desv, int num_ptos=10, string aux="salida.tmp")
{
   double x[num_ptos], y[num_ptos];
   ofstream salida(aux,std::ios_base::app);
   for(j=0;j<num_ptos;j++)
   {
      x[j]=(j/(num_ptos*1.0))*(6*desv)+(pos-(3*desv));
      y[j]=maxi*pow(e,-(  pow(x[j]-pos,2) )/( 2*pow(desv,2) ) );
      salida<<x[j]<<" "<<y[j]<<endl;
   }
}
int int_pipe(string cmd,int defecto=0)
{
   string data;
   FILE * stream;
   const int max_buffer = 256;
   char buffer[max_buffer];
   cmd.append(" 2>&1");
   stream = popen(cmd.c_str(), "r");
   if (stream)
   {
      while (!feof(stream))
      if (fgets(buffer, max_buffer, stream) != NULL) data.append(buffer);
      pclose(stream);
   }
   if(data.length()>1)
   {
      return stoi(data);
   }
   else
   {
      return defecto;
   }
}
int main(int argc, char **argv)
{
ifstream current(argv[1]);
Nat=stoi(argv[2]);
desv=stod(argv[3]);
   for(i=0;i<Nat;i++)
   {
      current>>pos>>maxi;
      crear_gaussiana(pos,maxi,desv);
   }
current.close();

return 0;
}
