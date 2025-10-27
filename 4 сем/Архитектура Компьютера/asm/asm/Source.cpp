/*#include <iostream>
using namespace std;

void add_stack(long long int a, long long int b, long long int& sum)
{
  //����
  //a 8����
  //b 8����
  //sum 8����
  __asm
  {
	mov eax, [ebp + 8] // � ebp+8 - 4 ����� eax - 32 ����, � ��� ���� 64 ����
	mov ebx, [ebp + 16]//� = <32���><32���> b = <32���><32���> sum = <32 ���><32 ���>
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

  //�������� ����� ����
  add_stack(a, b, sum);
  cout << "����� ����� ����: " << sum << endl;
  sum = 0;

  //�������� ����� ��������
  __asm
  {
	lea ebx, a
	lea edx, b
	lea esi, sum
  }
  add_reg();
  cout << "����� ����� ��������: " << sum << endl;
  sum = 0;

  //�������� ����� ���������� ����������
  globA = a;
  globB = b;
  globSum = &sum;
  add_global();
  cout << "����� ����� ���������� ����������: " << sum << endl;
  return 0;
}*/