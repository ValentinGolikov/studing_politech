#include <windows.h>
#include <iostream>
#include <string>
#include <fstream>

using std::cin;
using std::cout;
using std::endl;
using std::cerr;
using std::ifstream;
using std::string;

void main()
{
  setlocale(LC_ALL, "rus");
  string sFileName;
  BITMAPFILEHEADER bmpFileHeader;
  BITMAPINFOHEADER bmpInfoHeader;
  int Width, Height;
  RGBQUAD Palette[2];
  RGBTRIPLE* inBuf;
  BYTE* outBuf;
  HANDLE hInputFile, hOutFile;
  DWORD RW;

  hInputFile = CreateFile(L"test.bmp", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
  if (hInputFile == INVALID_HANDLE_VALUE) return;
  hOutFile = CreateFile(L"output.bmp", GENERIC_WRITE, 0, NULL, CREATE_NEW, 0, NULL);

  // Считываем инфу
  ReadFile(hInputFile, &bmpFileHeader, sizeof(bmpFileHeader), &RW, NULL);
  ReadFile(hInputFile, &bmpInfoHeader, sizeof(bmpInfoHeader), &RW, NULL);

  // Установим указатель на начало растра
  SetFilePointer(hInputFile, bmpFileHeader.bfOffBits, NULL, FILE_BEGIN);
  Width = bmpInfoHeader.biWidth;
  Height = bmpInfoHeader.biHeight;

  // Выделим память
  inBuf = new RGBTRIPLE[Width];
  outBuf = new BYTE[Width / 8];
  cout << "Разрешение изображения: ";
  cout << Width << "x" << Height << endl;
  cout << "Количество бит на пиксел: " << bmpInfoHeader.biBitCount << endl;
  cout << "Размер изображения: " << bmpFileHeader.bfSize << " байт" << endl;
  /*
  cout << bmpFileHeader.bfOffBits << endl;
  cout << bmpInfoHeader.biCompression << endl;
  cout << bmpInfoHeader.biSizeImage << endl;
*/
  // Заполним заголовки
  bmpFileHeader.bfOffBits = sizeof(bmpFileHeader) + sizeof(bmpInfoHeader) + 8;
  bmpInfoHeader.biBitCount = 1;
  bmpInfoHeader.biCompression = 0;
  bmpFileHeader.bfSize = bmpFileHeader.bfOffBits + (Width * Height * 0.125) + 1 / 8 * Height * Width % 4;

  // Запишем заголовки
  WriteFile(hOutFile, &bmpFileHeader, sizeof(bmpFileHeader), &RW, NULL);
  WriteFile(hOutFile, &bmpInfoHeader, sizeof(bmpInfoHeader), &RW, NULL);


  Palette[0].rgbBlue = 0;
  Palette[0].rgbGreen = 0;
  Palette[0].rgbRed = 0;
  Palette[1].rgbBlue = 255;
  Palette[1].rgbGreen = 255;
  Palette[1].rgbRed = 255;


  WriteFile(hOutFile, Palette, 2 * sizeof(RGBQUAD), &RW, NULL);

  int binarizationThreshold = 0;
  cout << "Введите порог бинаризации (число от 0 до 255) : ";
  cin >> binarizationThreshold;

  // Начнем преобразовывать
  for (int i = 0; i < Height; i++)
  {
    ReadFile(hInputFile, inBuf, sizeof(RGBTRIPLE) * Width, &RW, NULL);
    int k = 0;
    for (int j = 0; j < (Width / 8) && k < Width; j++)
    {
      outBuf[j] = 0;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x80; //1000000
      k++;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x40;
      k++;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x20;
      k++;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x10;
      k++;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x08;
      k++;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x04;
      k++;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x02;
      k++;
      if ((inBuf[k].rgbtBlue + inBuf[k].rgbtGreen + inBuf[k].rgbtRed) / 3 > binarizationThreshold) outBuf[j] = outBuf[j] | 0x01;
      k++;
    }
    //0.33 * ((inBuf[k].rgbtBlue & 0xF0) / 16 + 0.34 * (inBuf[k].rgbtGreen & 0xF0) / 16 + 0.33 * (inBuf[k].rgbtRed & 0xF0) / 16) * 16
    WriteFile(hOutFile, outBuf, sizeof(BYTE) * Width / 8, &RW, NULL);
    // Пишем мусор для выравнивания
    WriteFile(hOutFile, Palette, Width % 4, &RW, NULL);
    SetFilePointer(hInputFile, Width % 4, NULL, FILE_CURRENT);
  }
  delete[] inBuf;
  delete[] outBuf;
  CloseHandle(hInputFile);
  CloseHandle(hOutFile);
  system("pause");
}