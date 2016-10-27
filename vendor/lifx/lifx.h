#include <stdlib.h>
#include <arpa/inet.h>
#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

int lifx_lan_open_socket(void);
void lifx_lan_close_socket(int fd);
void lifx_lan_lights_off(int fd, uint16_t seqnum, uint64_t target);
void lifx_lan_lights_on(int fd, uint16_t seqnum, uint64_t target);
void lifx_lan_set_color(int fd, uint16_t seqnum, uint64_t target, uint16_t hue, uint16_t saturation, uint16_t brightness, uint16_t kelvin, uint32_t duration_millis);
