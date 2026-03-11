/*
 * N1OS Shell — Entry point
 * Custom Wayland compositor for PinePhone
 */

#include "n1shell.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int64_t n1_time_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
}

static void print_banner(void) {
    printf("\n");
    printf("    ███╗   ██╗ ██╗ ██████╗ ███████╗\n");
    printf("    ████╗  ██║███║██╔═══██╗██╔════╝\n");
    printf("    ██╔██╗ ██║╚██║██║   ██║███████╗\n");
    printf("    ██║╚██╗██║ ██║██║   ██║╚════██║\n");
    printf("    ██║ ╚████║ ██║╚██████╔╝███████║\n");
    printf("    ╚═╝  ╚═══╝ ╚═╝ ╚═════╝ ╚══════╝\n");
    printf("         Shell v1.0.0\n\n");
}

int main(int argc, char *argv[]) {
    (void)argc; (void)argv;
    print_banner();

    wlr_log_init(WLR_INFO, NULL);

    n1_server_t server = {0};
    server.accent_color = N1_DEFAULT_ACCENT;
    server.mode = N1_MODE_HOME;
    server.home_boot_anim = true;
    server.boot_start_ms = n1_time_ms();

    /* Load user config (accent color, tile layout) */
    n1_config_load(&server);

    /* Initialize compositor */
    if (n1_compositor_init(&server) != 0) {
        fprintf(stderr, "Failed to initialize compositor\n");
        return 1;
    }

    /* Load default tiles */
    n1_tiles_load_defaults(&server);
    n1_home_layout(&server);

    /* Initialize input handling */
    n1_input_init(&server);

    /* Run */
    printf("N1OS Shell running on Wayland\n");
    n1_compositor_run(&server);

    /* Cleanup */
    n1_compositor_destroy(&server);
    n1_config_save(&server);

    return 0;
}
