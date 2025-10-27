/*#include <iostream>

extern "C" void add_stack(long long int a, long long int b, long long int& sum) {
  __asm {
    mov rax, [rbp + 4]
    add rax, b
    mov sum, rax
  }
}

int main() {
  long long int a = 0x000000000000000A;
  long long int b = 0x000000000000000F;
  long long int sum = 0;

  add_stack(a, b, sum);

  std::cout << "Sum: " << sum << std::endl; // Вывод результата
  return 0;
}*/