/*#include <iostream>
using namespace std;

void add_stack(long long int a, long long int b, long long int& sum)
{
  //стек
  //a 8байт
  //b 8байт
  //sum 8байт
  __asm
  {
	mov eax, [ebp + 8] // с ebp+8 - 4 байта eax - 32 бита, а нам надо 64 бита
	mov ebx, [ebp + 16]//а = <32бит><32бит> b = <32бит><32бит> sum = <32 бит><32 бит>
	add eax, ebx
	mov esi, [ebp + 24]
	mov[esi], eax
	mov eax, [ebp + 12]
	mov ebx, [ebp + 20]
	adc eax, ebx
	mov[esi + 4], eax
  }
}

void add_reg()
{
  __asm
  {
	mov eax, [ebx]
	mov ecx, [edx]
	add eax, ecx
	mov[esi], eax
	mov eax, [ebx + 4]
	mov ecx, [edx + 4]
	adc eax, ecx
	mov[esi + 4], eax
  }
}


long long int globA = 0;
long long int globB = 0;
long long int* globSum = 0;

void add_global()
{
  __asm
  {
	lea ebx, globA
	lea edx, globB
	mov esi, globSum
	mov eax, [ebx]
	mov ecx, [edx]
	add eax, ecx
	mov[esi], eax
	mov eax, [ebx + 4]
	mov ecx, [edx + 4]
	adc eax, ecx
	mov[esi + 4], eax
  }
}


int main()
{
  setlocale(LC_ALL, "rus");
  long long int a = 0x000000000000000A;
  long long int b = 0x000000000000000F;
  long long int sum = 0;

  //передача через стек
  add_stack(a, b, sum);
  cout << "Сумма через стек: " << sum << endl;
  sum = 0;

  //передача через регистры
  __asm
  {
	lea ebx, a
	lea edx, b
	lea esi, sum
  }
  add_reg();
  cout << "Сумма через регистры: " << sum << endl;
  sum = 0;

  //передача через глобальные переменные
  globA = a;
  globB = b;
  globSum = &sum;
  add_global();
  cout << "Сумма через глобальные переменные: " << sum << endl;
  return 0;
}*/