//  Created by Rodrigo Damazio on 24/01/10.
//  Strongly based on code found on http://www.cocoadev.com/index.pl?SoundVolume
//  Modified by Brendan Caffrey, originally from https://code.google.com/p/android-notifier/

#include "volume_switch.h"

AudioDeviceID getOutputDeviceId() {
  AudioDeviceID deviceID = kAudioDeviceUnknown;
  UInt32 propertySize = sizeof(deviceID);
  AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &propertySize, &deviceID);
  return deviceID;
}

float getOutputVolume() {
  Float32 outputVolume;
  UInt32 propertySize = 0;
  OSStatus status = noErr;

  AudioObjectPropertyAddress propertyAOPA;
  propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
  propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
  propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;

  AudioDeviceID outputDeviceID = getOutputDeviceId();
  if (outputDeviceID == kAudioObjectUnknown) return 0.0f;
  if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) return 0.0f;

  propertySize = (UInt32) sizeof(Float32);
  status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume);
  if (status) return 0.0f;

  if (outputVolume < 0.0f) return 0.0f;
  if (outputVolume > 1.0f) return 1.0f;

  return outputVolume;
}

void setOutputVolume(float newVolume) {
  if (newVolume < 0.0f) newVolume = 0.0f;
  if (newVolume > 1.0f) newVolume = 1.0f;

  UInt32 propertySize = 0;
  OSStatus status = noErr;

  AudioObjectPropertyAddress propertyAOPA;
  propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
  propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
  propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;

  AudioDeviceID outputDeviceID = getOutputDeviceId();
  if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) return;

  Boolean canSetVolume = false;
  status = AudioHardwareServiceIsPropertySettable(outputDeviceID, &propertyAOPA, &canSetVolume);
  if (status || canSetVolume == false) return;

  propertySize = (UInt32) sizeof(Float32);
  status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &newVolume);	

  propertyAOPA.mSelector = kAudioDevicePropertyMute;
  propertySize = (UInt32) sizeof(UInt32);
  UInt32 mute = 0;
  if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) return;

  Boolean canSetMute = false;
  status = AudioHardwareServiceIsPropertySettable(outputDeviceID, &propertyAOPA, &canSetMute);
  if (status || !canSetMute) return;
  status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
}
