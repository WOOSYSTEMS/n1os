/*
 * N1OS Shell — Tile management
 * Metro-style live tiles for the home screen
 */

#include "n1shell.h"
#include <string.h>
#include <stdio.h>

/* Default tile layout — core PinePhone apps */
void n1_tiles_load_defaults(n1_server_t *server) {
    int i = 0;

    /* Row 1: Phone (large, 2x1 wide) */
    server->tiles[i] = (n1_tile_t){
        .name = "Phone",
        .icon = "📞",
        .exec_cmd = "n1-phone",
        .size = TILE_SIZE_MEDIUM,
        .has_live_content = true,
        .live_text = "No missed calls",
        .live_count = 0,
    };
    i++;

    /* Row 2: Messages + Camera */
    server->tiles[i] = (n1_tile_t){
        .name = "Messages",
        .icon = "💬",
        .exec_cmd = "n1-messages",
        .size = TILE_SIZE_SMALL,
        .has_live_content = true,
        .live_text = "2 new messages",
        .live_count = 2,
    };
    i++;

    server->tiles[i] = (n1_tile_t){
        .name = "Camera",
        .icon = "📷",
        .exec_cmd = "megapixels",
        .size = TILE_SIZE_SMALL,
        .accent_color = 0x37474f,
    };
    i++;

    /* Row 3: Browser (large 2x2) */
    server->tiles[i] = (n1_tile_t){
        .name = "Browser",
        .icon = "🌐",
        .exec_cmd = "firefox",
        .size = TILE_SIZE_LARGE,
        .accent_color = 0x1565c0,
    };
    i++;

    /* Row 5: Settings + Files */
    server->tiles[i] = (n1_tile_t){
        .name = "Settings",
        .icon = "⚙",
        .exec_cmd = "n1-settings",
        .size = TILE_SIZE_SMALL,
        .accent_color = 0x424242,
    };
    i++;

    server->tiles[i] = (n1_tile_t){
        .name = "Files",
        .icon = "📁",
        .exec_cmd = "nnn",
        .size = TILE_SIZE_SMALL,
        .accent_color = 0x795548,
    };
    i++;

    /* Row 6: Music (wide) */
    server->tiles[i] = (n1_tile_t){
        .name = "Music",
        .icon = "🎵",
        .exec_cmd = "n1-music",
        .size = TILE_SIZE_MEDIUM,
        .accent_color = 0x6a1b9a,
        .has_live_content = true,
        .live_text = "Now playing: Nothing",
    };
    i++;

    /* Row 7: Terminal + WiFi */
    server->tiles[i] = (n1_tile_t){
        .name = "Terminal",
        .icon = ">_",
        .exec_cmd = "foot",
        .size = TILE_SIZE_SMALL,
        .accent_color = 0x212121,
    };
    i++;

    server->tiles[i] = (n1_tile_t){
        .name = "WiFi",
        .icon = "📶",
        .exec_cmd = "iwgtk",
        .size = TILE_SIZE_SMALL,
        .accent_color = 0x00838f,
        .has_live_content = true,
        .live_text = "Not connected",
    };
    i++;

    /* Row 8: Weather (wide) */
    server->tiles[i] = (n1_tile_t){
        .name = "Weather",
        .icon = "☀",
        .exec_cmd = "n1-weather",
        .size = TILE_SIZE_MEDIUM,
        .accent_color = 0x0277bd,
        .has_live_content = true,
        .live_text = "23°C Partly Cloudy",
    };
    i++;

    /* Row 9: Maps + Clock */
    server->tiles[i] = (n1_tile_t){
        .name = "Maps",
        .icon = "🗺",
        .exec_cmd = "gnome-maps",
        .size = TILE_SIZE_SMALL,
        .accent_color = 0x2e7d32,
    };
    i++;

    server->tiles[i] = (n1_tile_t){
        .name = "Clock",
        .icon = "🕐",
        .exec_cmd = "n1-clock",
        .size = TILE_SIZE_SMALL,
        .accent_color = 0x283593,
        .has_live_content = true,
        .live_text = "",
    };
    i++;

    server->tile_count = i;

    /* Set stagger delays for boot animation */
    for (int t = 0; t < server->tile_count; t++) {
        server->tiles[t].anim_progress = 0.0f;
        server->tiles[t].stagger_delay_ms = t * N1_TILE_STAGGER_MS;
    }
}

/* Hit test — returns tile index or -1 */
int n1_tile_hit_test(n1_server_t *server, double x, double y) {
    /* Adjust for scroll */
    double adj_y = y + server->home_scroll_y;

    for (int i = 0; i < server->tile_count; i++) {
        n1_tile_t *tile = &server->tiles[i];
        if (x >= tile->x && x <= tile->x + tile->w &&
            adj_y >= tile->y && adj_y <= tile->y + tile->h) {
            return i;
        }
    }
    return -1;
}
