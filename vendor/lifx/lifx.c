#include <arpa/inet.h>
#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define LIFX_LAN_PORT              56700
#define LIFX_LAN_PROTOCOL          1024
#define LIFX_LAN_LEVEL_POWERED_ON  65535
#define LIFX_LAN_LEVEL_POWERED_OFF 0

#define LIFX_LAN_MESSAGE_TYPE_DEVICE_SET_POWER 21
#define LIFX_LAN_MESSAGE_TYPE_LIGHT_SET_COLOR  102

#pragma pack(push, 1)
struct lifx_lan_header
{
    uint16_t size; // size of entire message, including this field
    uint16_t protocol:12; // must be 1024
    uint8_t  addressable:1; // must be 1
    uint8_t  tagged:1; // determines usage of target field
    uint8_t  origin:2; // must be 0
    uint32_t source; // set by client, used by responses
    uint64_t target; // 6 byte MAC to target specific bulb (left padded w/ 0's) or 0 for all
    uint8_t  reserved[6];
    uint8_t  res_required:1;
    uint8_t  ack_required:1;
    uint8_t  :6; // reserved
    uint8_t  sequence; // wrap around sequence number
    uint64_t :64; // reserved
    uint16_t type; // message type
    uint16_t :16; // reserved
};

struct lifx_lan_device_set_power
{
    struct lifx_lan_header header;
    uint16_t level;
};

struct lifx_lan_light_set_color
{
    struct lifx_lan_header header;
    uint8_t reserved;
    uint16_t hue;
    uint16_t saturation;
    uint16_t brightness;
    uint16_t kelvin;
    uint32_t duration_millis;
};
#pragma pack(pop)

int lifx_lan_open_socket_(void)
{
    int fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (fd == -1) return -1;

    int bcast_enable = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &bcast_enable, sizeof(bcast_enable)) != 0) return -1;

    return fd;
}

void lifx_lan_close_socket_(int fd)
{
    close(fd);
}

void lifx_lan_send_(int fd, void* msg, size_t msg_size)
{
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(LIFX_LAN_PORT);
    addr.sin_addr.s_addr = htonl(-1);

    sendto(fd, msg, msg_size, 0, (struct sockaddr*) &addr, sizeof(struct sockaddr_in));
}

void lifx_lan_encode_header_(struct lifx_lan_header* header, char type, size_t msg_size, uint16_t seqnum)
{
    memset(header, 0, sizeof(struct lifx_lan_header));
    assert(msg_size < UINT16_MAX);

    header->size = msg_size;
    header->protocol = LIFX_LAN_PROTOCOL;
    header->addressable = 1;
    header->tagged = 1;
    header->type = type;
    header->res_required = 1;
}

void lifx_lan_lights_off(void)
{
    int fd = lifx_lan_open_socket_();
    if (fd == -1) return;

    struct lifx_lan_device_set_power msg;
    lifx_lan_encode_header_(&msg.header, LIFX_LAN_MESSAGE_TYPE_DEVICE_SET_POWER, sizeof(msg), 0);
    msg.level = LIFX_LAN_LEVEL_POWERED_OFF;

    lifx_lan_send_(fd, &msg, sizeof(msg));
    lifx_lan_close_socket_(fd);
}

void lifx_lan_set_color(uint16_t hue, uint16_t saturation, uint16_t brightness, uint16_t kelvin)
{
    int fd = lifx_lan_open_socket_();
    if (fd == -1) return;

    struct lifx_lan_device_set_power power_msg;
    lifx_lan_encode_header_(&power_msg.header, LIFX_LAN_MESSAGE_TYPE_DEVICE_SET_POWER, sizeof(power_msg), 0);
    power_msg.level = LIFX_LAN_LEVEL_POWERED_ON;

    struct lifx_lan_light_set_color color_msg;
    lifx_lan_encode_header_(&color_msg.header, LIFX_LAN_MESSAGE_TYPE_LIGHT_SET_COLOR, sizeof(color_msg), 1);
    color_msg.hue = hue;
    color_msg.saturation = saturation;
    color_msg.brightness = brightness;
    color_msg.kelvin = kelvin;
    color_msg.duration_millis = 0;

    lifx_lan_send_(fd, &power_msg, sizeof(power_msg));
    lifx_lan_send_(fd, &color_msg, sizeof(color_msg));
    lifx_lan_close_socket_(fd);
}
