/*
 *  audio_switch.c
 *  AudioSwitcher

Copyright (c) 2008 Devon Weller <wellerco@gmail.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Modified by Brendan Caffrey, originally from https://github.com/deweller/switchaudio-osx

 */

#include "audio_switch.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

bool isAnOutputDevice(AudioDeviceID deviceID) {
    UInt32 propertySize = 256;

    // if there are any output streams, then it is an output
    AudioDeviceGetPropertyInfo(deviceID, 0, false, kAudioDevicePropertyStreams, &propertySize, NULL);
    if (propertySize > 0) return true;

    return false;
}

AudioDeviceID getCurrentOutputDeviceId() {
    AudioDeviceID deviceID = kAudioDeviceUnknown;
    UInt32 propertySize = sizeof(deviceID);
    AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &propertySize, &deviceID);
    return deviceID;
}

void getDeviceNameFromId(AudioDeviceID deviceID, char * deviceName) {
    UInt32 propertySize = 256;
    AudioDeviceGetProperty(deviceID, 0, false, kAudioDevicePropertyDeviceName, &propertySize, deviceName);
}

char* getCurrentOutputDeviceName() {
    char *currentDeviceName = (char *) malloc(sizeof(char)*256);
    getDeviceNameFromId(getCurrentOutputDeviceId(), currentDeviceName);
    return currentDeviceName;
}

AudioDeviceID getOutputDeviceIdFromName(char* requestedDeviceName) {
    UInt32 propertySize;
    AudioDeviceID dev_array[64];
    int numberOfDevices = 0;
    char deviceName[256];

    AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &propertySize, NULL);
    AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &propertySize, dev_array);
    numberOfDevices = (propertySize / sizeof(AudioDeviceID));

    for(int i = 0; i < numberOfDevices; ++i) {
        if (!isAnOutputDevice(dev_array[i])) continue;

        getDeviceNameFromId(dev_array[i], deviceName);
        if (strcmp(requestedDeviceName, deviceName) == 0) return dev_array[i];
    }

    return kAudioDeviceUnknown;
}

void setOutputDeviceId(AudioDeviceID newDeviceID) {
    UInt32 propertySize = sizeof(UInt32);
    AudioHardwareSetProperty(kAudioHardwarePropertyDefaultOutputDevice, propertySize, &newDeviceID);
}

void setOutputDeviceByName(char* requestedDeviceName) {
    AudioDeviceID chosenDeviceID = getOutputDeviceIdFromName(requestedDeviceName);
    setOutputDeviceId(chosenDeviceID);
}

#pragma GCC diagnostic pop

