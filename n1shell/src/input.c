/*
 * N1OS Shell — Input handling
 * Touch input via libinput, mapped to PinePhone DSI-1 display
 */

#include "n1shell.h"
#include <stdio.h>
#include <string.h>

/* ─── Touch Point Management ─── */

static n1_touch_point_t *find_touch(n1_server_t *server, int32_t id) {
    for (int i = 0; i < N1_MAX_TOUCH_POINTS; i++) {
        if (server->touches[i].active && server->touches[i].id == id) {
            return &server->touches[i];
        }
    }
    return NULL;
}

static n1_touch_point_t *alloc_touch(n1_server_t *server, int32_t id) {
    for (int i = 0; i < N1_MAX_TOUCH_POINTS; i++) {
        if (!server->touches[i].active) {
            memset(&server->touches[i], 0, sizeof(n1_touch_point_t));
            server->touches[i].id = id;
            server->touches[i].active = true;
            return &server->touches[i];
        }
    }
    return NULL;
}

/* ─── Wayland Input Callbacks ─── */

static void handle_touch_down(struct wl_listener *listener, void *data) {
    struct wlr_touch_down_event *event = data;
    n1_server_t *server = wl_container_of(listener, server, new_input);

    /* Map normalized coords to screen pixels */
    double x = event->x * server->screen_width;
    double y = event->y * server->screen_height;

    n1_input_handle_touch_down(server, event->touch_id, x, y);
}

static void handle_touch_up(struct wl_listener *listener, void *data) {
    struct wlr_touch_up_event *event = data;
    n1_server_t *server = wl_container_of(listener, server, new_input);

    n1_input_handle_touch_up(server, event->touch_id);
}

static void handle_touch_motion(struct wl_listener *listener, void *data) {
    struct wlr_touch_motion_event *event = data;
    n1_server_t *server = wl_container_of(listener, server, new_input);

    double x = event->x * server->screen_width;
    double y = event->y * server->screen_height;

    n1_input_handle_touch_motion(server, event->touch_id, x, y);
}

/* ─── Public Input Functions ─── */

void n1_input_init(n1_server_t *server) {
    memset(server->touches, 0, sizeof(server->touches));
}

void n1_input_handle_touch_down(n1_server_t *server, int32_t id,
                                 double x, double y) {
    n1_touch_point_t *tp = alloc_touch(server, id);
    if (!tp) return;

    tp->start_x = tp->current_x = x;
    tp->start_y = tp->current_y = y;
    tp->velocity_x = tp->velocity_y = 0;
    tp->start_time_ms = tp->last_time_ms = n1_time_ms();

    /* Dispatch to current mode */
    switch (server->mode) {
        case N1_MODE_HOME:
            n1_home_touch(server, tp, 0);
            break;
        case N1_MODE_SWITCHER:
            n1_switcher_touch(server, tp, 0);
            break;
        case N1_MODE_APP:
            /* Forward to active toplevel via wlr_seat */
            break;
    }
}

void n1_input_handle_touch_motion(n1_server_t *server, int32_t id,
                                   double x, double y) {
    n1_touch_point_t *tp = find_touch(server, id);
    if (!tp) return;

    int64_t now = n1_time_ms();
    float dt = (now - tp->last_time_ms) / 1000.0f;
    if (dt > 0.001f) {
        /* Exponential moving average for velocity */
        float vx = (x - tp->current_x) / dt;
        float vy = (y - tp->current_y) / dt;
        tp->velocity_x = tp->velocity_x * 0.6f + vx * 0.4f;
        tp->velocity_y = tp->velocity_y * 0.6f + vy * 0.4f;
    }

    tp->current_x = x;
    tp->current_y = y;
    tp->last_time_ms = now;

    switch (server->mode) {
        case N1_MODE_HOME:
            n1_home_touch(server, tp, 1);
            break;
        case N1_MODE_SWITCHER:
            n1_switcher_touch(server, tp, 1);
            break;
        case N1_MODE_APP:
            break;
    }
}

void n1_input_handle_touch_up(n1_server_t *server, int32_t id) {
    n1_touch_point_t *tp = find_touch(server, id);
    if (!tp) return;

    switch (server->mode) {
        case N1_MODE_HOME:
            n1_home_touch(server, tp, 2);
            break;
        case N1_MODE_SWITCHER:
            n1_switcher_touch(server, tp, 2);
            break;
        case N1_MODE_APP:
            /* Check for edge swipe gestures */
            {
                float dy = tp->current_y - tp->start_y;
                /* Swipe up from bottom = home */
                if (tp->start_y > server->screen_height - 50 && dy < -100) {
                    server->mode = N1_MODE_HOME;
                    printf("N1: Gesture -> Home\n");
                }
                /* Swipe from left edge = back */
                if (tp->start_x < 30 && tp->current_x - tp->start_x > 80) {
                    server->mode = N1_MODE_HOME;
                    printf("N1: Gesture -> Back\n");
                }
            }
            break;
    }

    tp->active = false;
}
