#include <iostream>
#include <iomanip>
#include <cmath>	
#include <format>	
#include "cmathsrc\cmath.h"		//lib for QUANC8, SPLINE, SEVAL
#include "cmathsrc\RCS\quanc8.c"
#include "cmathsrc\spline.c"

using namespace std;

const int A = 0;		//левая граница интервала х
const int B = 2;		//правая граница интервала х
const double H = 0.2;	//шаг интервала х
const int num_value = (B - A) / H + 1;	//количество вычисляемых значений (от 0 до 2 с шагом 0.2 = 11)

double t;	//дополнительная перемнная для корректной работы fun и quanc8
double result, errest, posn, answer = 0;
int col, flag = 0;

double fun(double x) {
	return exp(x*t) * sin(t);
}

double omegak(double x, int k) {
  double res = 1, xk = A;
  for (int i = 0; i < num_value; i++) {
	if (i != k) {
	  res *= x - xk;
	}
	xk += H;
  }
  return res;
}

double lagrange(double x, double* f) {
  double res = 0, xk = A;
  for (int j = 0; j < 10; j++) {
	res += (omegak(x, j) / omegak(xk, j)) * f[j];
	xk += H;
  }
  return res;
}

void sep() {
	cout << "\n";
	for (int i = 0; i < 100; i++) {
		cout << "#";
	}
	cout << "\n\n";
}

int main() {
	cout.precision(7);
	setlocale(LC_ALL, "rus");
	//QUANC8
	double x[11] = {0}, f[11] = {0};
	cout << "\t\tВычисление интеграла с помощью QUANC8\n\n";
	cout << " Узел\t\t  Результат\t    Погршеность\t\tКол-во вычислений\tнадёжность\n";
	int k = 1;
	for (int i = 0; i < num_value; i++) {
		quanc8(fun, 0, 1, 0.000001, 0.000001, &result, &errest, &col, &posn, &flag);
		cout << "X = " << t << "\t\tint = " << result << "\terrest = " << errest << "\t    col = "
			<< col << "\t\t flag = " << flag << endl;
		x[i] = t;
		f[i] = result;
		t = (k - 0.5) * H;
		k++;
	}
	sep();
	
	//SPLINE
	double b[11] = { 0 }, c[11] = { 0 }, d[11] = { 0 };
	
	spline(num_value, 0, 0, 0, 0, x, f, b, c, d, &flag);
	cout << "\t\tСравнение SPLINE и QUANC8\n";
	cout << "----------------------------------------------------------------------------------------------------\n"
			"\tX\t|\t QUANC8 \t SPLINE \t QUANC8-SEVAL\n"
			"----------------------------------------------------------------------------------------------------\n";
	t = A;
	while (t <= B) {
		quanc8(fun, 0, 1, 0.000001, 0.000001, &result, &errest, &col, &posn, &flag);
		answer = seval(num_value, t, x, f, b, c, d, &flag);
		if (t == 0) cout << "\t" << t << "\t|\t" << result << "    " << answer << "    " << (result - answer) << endl;
		else cout << "\t" << t << "\t|\t" << result << "    " << answer << "    " << (result - answer) << endl;
		t += 0.1;
	}

	sep();
	//LAGRANGE
	cout << "\t\tСравнение LAGRANGE и QUANC8\n";
	cout << "----------------------------------------------------------------------------------------------------\n"
	  "\tX\t|\t QUANC8 \tLAGRANGE\tQUANC8-LAGRANGE\n"
	  "----------------------------------------------------------------------------------------------------\n";
	t = A;
	while (t <= B) {
	  quanc8(fun, 0, 1, 0.000001, 0.000001, &result, &errest, &col, &posn, &flag);
	  answer = lagrange(t, f);
	  if (t == 0) cout << "\t" << t << "\t|\t" << result << "    " << answer << "    " << (result - answer) << endl;
	  else cout << "\t" << t << "\t|\t" << result << "    " << answer << "    " << (result - answer) << endl;
	  t += 0.1;
	}

	return EXIT_SUCCESS;
}