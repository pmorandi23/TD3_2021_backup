#include <iostream>

using namespace std;
extern "C" int suma (int,int);
int main ()
{
	int op1 = 234;
	int op2 = 345;
	cout << op1 << " + " << op2 << " = " << suma (op1,op2) << endl;
	return 0;

}
