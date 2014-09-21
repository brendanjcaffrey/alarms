//
//  SoundController.m
//
//  Serial Remote for Mac - Control mac actions via serial commands
//  Copyright (C) 2010  Jeremiah McConnell
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Originally from http://serial-remote-mac.googlecode.com/svn-history/r11/trunk/SoundController.m,
//  modified here

#include "volume_switch.h"

AudioDeviceID outputDeviceID = kAudioObjectUnknown;

void getOutputDeviceId() {
  UInt32 propertySize = 0;
  OSStatus status = noErr;
  AudioObjectPropertyAddress propertyAOPA;

  propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
  propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
  propertyAOPA.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
  propertySize = sizeof(AudioDeviceID);

  status = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject, &propertyAOPA, 0, NULL, &propertySize, &outputDeviceID); 

  if(status) {
    printf("Error setting output device id");
    // Error
    return;
  }
}

float getOutputVolume() {
  getOutputDeviceId();

  Float32 outputVolume;
  UInt32 propertySize = 0;
  OSStatus status = noErr;
  AudioObjectPropertyAddress propertyAOPA;

  propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
  propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
  propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
  propertySize = sizeof(Float32);

  status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume);

  if(status) {
    printf("getOutputVolume error");
    return 0.5;
  }

  if (outputVolume < 0.0) return 0.0;
  else if (outputVolume > 1.0) return 1.0;
  else return outputVolume;
}

void setOutputVolume(float newVolume) {
  if (newVolume < 0.0f) newVolume = 0.0f;
  if (newVolume > 1.0f) newVolume = 1.0f;

  getOutputDeviceId();

  UInt32 propertySize = 0;
  OSStatus status = noErr;
  AudioObjectPropertyAddress propertyAOPA;
  propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
  propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;

  if (newVolume < 0.001) {
    propertyAOPA.mSelector = kAudioDevicePropertyMute;
    propertySize = sizeof(UInt32);
    UInt32 mute = 1;
    status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);

    if(status) {
      printf("Unable to mute device");
      return;
    }
  } else {
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    Float32 volumeToSet = newVolume;
    propertySize = sizeof(Float32);

    status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &volumeToSet);

    if(status) {
      printf("Unable to set volume.\n");
      // Error
      return;
    }

    // make sure we're not muted
    propertyAOPA.mSelector = kAudioDevicePropertyMute;
    propertySize = sizeof(UInt32);
    UInt32 mute = 0;

    status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);

    if(status) {
      printf("Unable to unmute\n");
      // Error
      return;
    }
  }
}
