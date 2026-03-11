/*
 * N1OS Shell — Configuration
 * Persists accent color and tile layout
 */

#include "n1shell.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N1_CONFIG_PATH "/home/n1os/.config/n1shell/config"

void n1_config_load(n1_server_t *server) {
    FILE *f = fopen(N1_CONFIG_PATH, "r");
    if (!f) {
        server->accent_color = N1_DEFAULT_ACCENT;
        return;
    }

    char line[256];
    while (fgets(line, sizeof(line), f)) {
        if (strncmp(line, "accent=", 7) == 0) {
            server->accent_color = (uint32_t)strtol(line + 7, NULL, 16);
        }
    }
    fclose(f);
}

void n1_config_save(n1_server_t *server) {
    /* Ensure directory exists */
    system("mkdir -p /home/n1os/.config/n1shell");

    FILE *f = fopen(N1_CONFIG_PATH, "w");
    if (!f) return;

    fprintf(f, "accent=%06x\n", server->accent_color);
    fclose(f);
}
