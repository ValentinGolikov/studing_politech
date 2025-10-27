#include <iostream>
#include <windows.h>
#include "fmod.hpp"
#include "fmod_errors.h"

#pragma comment(lib, "fmodL_vc.lib")

void ERRCHECK(FMOD_RESULT result)
{
  if (result != FMOD_OK)
  {
    std::cerr << "FMOD error! (" << result << ") "
      << FMOD_ErrorString(result) << std::endl;
    exit(-1);
  }
}

int main()
{
  FMOD::System* system = nullptr;
  FMOD_RESULT result;

  // ������� �������
  result = FMOD::System_Create(&system);
  ERRCHECK(result);

  // �������������� ������� � 32 ��������
  result = system->init(32, FMOD_INIT_NORMAL, 0);
  ERRCHECK(result);

  // ��������� ��������� � ������
  FMOD::Sound* sound = nullptr;
  //result = system->createSound("windows-xp-startup.mp3", FMOD_DEFAULT, 0, &sound);
  result = system->createSound("iphone-11-pro.mp3", FMOD_DEFAULT, 0, &sound);
  ERRCHECK(result);

  // ����������� ����
  FMOD::Channel* channel = nullptr;
  result = system->playSound(sound, nullptr, false, &channel);
  ERRCHECK(result);

  // ������� DSP-������ ���
  FMOD::DSP* echoDSP = nullptr;
  result = system->createDSPByType(FMOD_DSP_TYPE_ECHO, &echoDSP);
  ERRCHECK(result);

  // ��������� ������ � ������� DSP ������ (�� ������� 0, �� ���� � ������)
  result = channel->addDSP(0, echoDSP);
  ERRCHECK(result);

  // ����������� ��������� �������:
  // �������� 350 �� � �������� ����� 70%
  result = echoDSP->setParameterFloat(FMOD_DSP_ECHO_DELAY, 350.0f);
  ERRCHECK(result);
  result = echoDSP->setParameterFloat(FMOD_DSP_ECHO_FEEDBACK, 70.0f);
  ERRCHECK(result);

  // �����������, ��� ������ �������
  result = echoDSP->setActive(true);
  ERRCHECK(result);

  std::cout << "Playing sound with echo effect. Press Enter to quit.\n";
  std::cin.get();

  // ����������� �������: ������, ����, �������
  result = echoDSP->release();
  ERRCHECK(result);
  result = sound->release();
  ERRCHECK(result);
  result = system->close();
  ERRCHECK(result);
  result = system->release();
  ERRCHECK(result);

  return 0;
}

