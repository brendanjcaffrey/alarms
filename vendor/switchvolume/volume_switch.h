//
//  SoundVolume.h
//  MacDroidNotifier
//
//  Created by Rodrigo Damazio on 24/01/10.
//
//  Modified by Brendan Caffrey, originally from https://code.google.com/p/android-notifier/

#include <AudioToolbox/AudioServices.h>

float getOutputVolume();
void setOutputVolume(float newVolume);
