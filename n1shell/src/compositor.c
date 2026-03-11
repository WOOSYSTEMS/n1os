/*
 * N1OS Shell — Compositor
 * wlroots-based Wayland compositor with scene graph
 */

#include "n1shell.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_data_device.h>
#include <wlr/types/wlr_subcompositor.h>

/* ─── XDG Toplevel (App Window) Handlers ─── */

struct n1_toplevel {
    struct wl_list link;
    n1_server_t *server;
    struct wlr_xdg_toplevel *xdg_toplevel;
    struct wlr_scene_tree *scene_tree;
    struct wl_listener map;
    struct wl_listener unmap;
    struct wl_listener commit;
    struct wl_listener destroy;
};

static void xdg_toplevel_map(struct wl_listener *listener, void *data) {
    struct n1_toplevel *toplevel = wl_container_of(listener, toplevel, map);
    n1_server_t *server = toplevel->server;

    /* Add as a card in the switcher */
    if (server->card_count < N1_MAX_VIEWS) {
        n1_card_t *card = &server->cards[server->card_count];
        card->toplevel = toplevel->xdg_toplevel;
        card->scene_tree = toplevel->scene_tree;
        card->x_offset = 0;
        card->x_velocity = 0;
        card->scale = 1.0f;
        card->opacity = 1.0f;
        card->accent_color = server->accent_color;
        card->is_closing = false;

        server->active_card_index = server->card_count;
        server->card_count++;
        server->active_toplevel = toplevel->xdg_toplevel;
        server->mode = N1_MODE_APP;

        printf("N1: App mapped (total: %d)\n", server->card_count);
    }

    /* Configure for fullscreen on PinePhone display */
    wlr_xdg_toplevel_set_size(toplevel->xdg_toplevel,
                               server->screen_width, server->screen_height);
}

static void xdg_toplevel_unmap(struct wl_listener *listener, void *data) {
    struct n1_toplevel *toplevel = wl_container_of(listener, toplevel, unmap);
    n1_server_t *server = toplevel->server;

    /* Remove from cards */
    for (int i = 0; i < server->card_count; i++) {
        if (server->cards[i].toplevel == toplevel->xdg_toplevel) {
            for (int j = i; j < server->card_count - 1; j++) {
                server->cards[j] = server->cards[j + 1];
            }
            server->card_count--;
            break;
        }
    }

    if (server->card_count == 0) {
        server->mode = N1_MODE_HOME;
        server->active_toplevel = NULL;
    }
}

static void xdg_toplevel_commit(struct wl_listener *listener, void *data) {
    /* Surface committed — schedule render */
}

static void xdg_toplevel_destroy(struct wl_listener *listener, void *data) {
    struct n1_toplevel *toplevel = wl_container_of(listener, toplevel, destroy);

    wl_list_remove(&toplevel->map.link);
    wl_list_remove(&toplevel->unmap.link);
    wl_list_remove(&toplevel->commit.link);
    wl_list_remove(&toplevel->destroy.link);
    free(toplevel);
}

static void handle_new_xdg_toplevel(struct wl_listener *listener, void *data) {
    n1_server_t *server = wl_container_of(listener, server, new_xdg_toplevel);
    struct wlr_xdg_toplevel *xdg_toplevel = data;

    struct n1_toplevel *toplevel = calloc(1, sizeof(*toplevel));
    toplevel->server = server;
    toplevel->xdg_toplevel = xdg_toplevel;
    toplevel->scene_tree = wlr_scene_xdg_surface_create(
        &server->scene->tree, xdg_toplevel->base);

    toplevel->map.notify = xdg_toplevel_map;
    wl_signal_add(&xdg_toplevel->base->surface->events.map, &toplevel->map);

    toplevel->unmap.notify = xdg_toplevel_unmap;
    wl_signal_add(&xdg_toplevel->base->surface->events.unmap, &toplevel->unmap);

    toplevel->commit.notify = xdg_toplevel_commit;
    wl_signal_add(&xdg_toplevel->base->surface->events.commit, &toplevel->commit);

    toplevel->destroy.notify = xdg_toplevel_destroy;
    wl_signal_add(&xdg_toplevel->events.destroy, &toplevel->destroy);
}

static void handle_new_xdg_popup(struct wl_listener *listener, void *data) {
    struct wlr_xdg_popup *popup = data;
    wlr_xdg_popup_get_toplevel_coords(popup, popup->current.geometry.x,
                                       popup->current.geometry.y, NULL, NULL);
}

/* ─── Output Handling ─── */

struct n1_output {
    struct wl_list link;
    n1_server_t *server;
    struct wlr_output *wlr_output;
    struct wl_listener frame;
    struct wl_listener destroy;
};

static void output_frame(struct wl_listener *listener, void *data) {
    struct n1_output *output = wl_container_of(listener, output, frame);
    n1_server_t *server = output->server;

    struct wlr_scene_output *scene_output =
        wlr_scene_get_scene_output(server->scene, output->wlr_output);

    /* Update animations */
    int64_t now = n1_time_ms();
    float dt = (now - server->last_frame_ms) / 1000.0f;
    if (dt > 0.1f) dt = 0.016f; /* Cap delta */
    server->last_frame_ms = now;

    switch (server->mode) {
        case N1_MODE_HOME:
            n1_home_update(server, dt);
            break;
        case N1_MODE_SWITCHER:
            n1_switcher_update(server, dt);
            break;
        case N1_MODE_APP:
            break;
    }

    /* Render scene graph (handles app surfaces) */
    wlr_scene_output_commit(scene_output, NULL);

    /* Overlay our shell UI */
    /* NOTE: In production, this would use wlr_renderer or a scene buffer
     * for the shell overlay. For now we render via the scene graph. */

    struct timespec now_ts;
    clock_gettime(CLOCK_MONOTONIC, &now_ts);
    wlr_scene_output_send_frame_done(scene_output, &now_ts);
}

static void output_destroy(struct wl_listener *listener, void *data) {
    struct n1_output *output = wl_container_of(listener, output, destroy);
    wl_list_remove(&output->frame.link);
    wl_list_remove(&output->destroy.link);
    wl_list_remove(&output->link);
    free(output);
}

static void handle_new_output(struct wl_listener *listener, void *data) {
    n1_server_t *server = wl_container_of(listener, server, new_output);
    struct wlr_output *wlr_output = data;

    /* Pick first available mode (PinePhone: 720x1440@60) */
    struct wlr_output_mode *mode = wlr_output_preferred_mode(wlr_output);
    if (mode) {
        struct wlr_output_state state;
        wlr_output_state_init(&state);
        wlr_output_state_set_mode(&state, mode);
        wlr_output_state_set_enabled(&state, true);
        wlr_output_commit_state(wlr_output, &state);
        wlr_output_state_finish(&state);
    }

    struct n1_output *output = calloc(1, sizeof(*output));
    output->server = server;
    output->wlr_output = wlr_output;

    output->frame.notify = output_frame;
    wl_signal_add(&wlr_output->events.frame, &output->frame);

    output->destroy.notify = output_destroy;
    wl_signal_add(&wlr_output->events.destroy, &output->destroy);

    wl_list_insert(&server->outputs, &output->link);

    /* Store screen dimensions */
    server->screen_width = wlr_output->width;
    server->screen_height = wlr_output->height;

    /* PinePhone DSI is portrait: 720x1440 */
    printf("N1: Output %s — %dx%d @ %d Hz\n",
           wlr_output->name,
           wlr_output->width, wlr_output->height,
           mode ? mode->refresh / 1000 : 0);

    /* Add to output layout */
    struct wlr_output_layout_output *l_output =
        wlr_output_layout_add_auto(server->output_layout, wlr_output);
    struct wlr_scene_output *scene_output =
        wlr_scene_output_create(server->scene, wlr_output);
    wlr_scene_output_layout_add_output(server->scene_layout,
                                        l_output, scene_output);

    /* Re-layout tiles for this screen size */
    n1_home_layout(server);
}

/* ─── Input Device Handling ─── */

static void handle_new_input(struct wl_listener *listener, void *data) {
    n1_server_t *server = wl_container_of(listener, server, new_input);
    struct wlr_input_device *device = data;

    switch (device->type) {
        case WLR_INPUT_DEVICE_TOUCH:
            printf("N1: Touch device: %s\n", device->name);
            /* Touch events come through wlr_cursor or directly */
            break;
        case WLR_INPUT_DEVICE_KEYBOARD:
            printf("N1: Keyboard: %s\n", device->name);
            break;
        default:
            break;
    }

    /* Set capabilities */
    uint32_t caps = WL_SEAT_CAPABILITY_TOUCH;
    wlr_seat_set_capabilities(server->seat, caps);
}

/* ─── Compositor Init ─── */

int n1_compositor_init(n1_server_t *server) {
    server->display = wl_display_create();
    if (!server->display) {
        fprintf(stderr, "N1: Failed to create Wayland display\n");
        return -1;
    }

    server->backend = wlr_backend_autocreate(
        wl_display_get_event_loop(server->display), NULL);
    if (!server->backend) {
        fprintf(stderr, "N1: Failed to create wlroots backend\n");
        return -1;
    }

    server->renderer = wlr_renderer_autocreate(server->backend);
    if (!server->renderer) {
        fprintf(stderr, "N1: Failed to create renderer\n");
        return -1;
    }
    wlr_renderer_init_wl_display(server->renderer, server->display);

    server->allocator = wlr_allocator_autocreate(
        server->backend, server->renderer);

    /* Scene graph */
    server->scene = wlr_scene_create();
    server->output_layout = wlr_output_layout_create(server->display);
    server->scene_layout = wlr_scene_attach_output_layout(
        server->scene, server->output_layout);

    /* Wayland protocols */
    wlr_compositor_create(server->display, 5, server->renderer);
    wlr_subcompositor_create(server->display);
    wlr_data_device_manager_create(server->display);

    /* XDG shell */
    server->xdg_shell = wlr_xdg_shell_create(server->display, 3);
    server->new_xdg_toplevel.notify = handle_new_xdg_toplevel;
    wl_signal_add(&server->xdg_shell->events.new_toplevel,
                  &server->new_xdg_toplevel);
    server->new_xdg_popup.notify = handle_new_xdg_popup;
    wl_signal_add(&server->xdg_shell->events.new_popup,
                  &server->new_xdg_popup);

    /* Output handling */
    wl_list_init(&server->outputs);
    server->new_output.notify = handle_new_output;
    wl_signal_add(&server->backend->events.new_output, &server->new_output);

    /* Input */
    server->seat = wlr_seat_create(server->display, "seat0");
    server->new_input.notify = handle_new_input;
    wl_signal_add(&server->backend->events.new_input, &server->new_input);

    /* Set default screen dims (PinePhone portrait) */
    server->screen_width = 720;
    server->screen_height = 1440;
    server->last_frame_ms = n1_time_ms();

    return 0;
}

void n1_compositor_run(n1_server_t *server) {
    const char *socket = wl_display_add_socket_auto(server->display);
    if (!socket) {
        fprintf(stderr, "N1: Failed to create Wayland socket\n");
        return;
    }

    if (!wlr_backend_start(server->backend)) {
        fprintf(stderr, "N1: Failed to start backend\n");
        return;
    }

    setenv("WAYLAND_DISPLAY", socket, true);
    printf("N1: Wayland compositor running on %s\n", socket);
    printf("N1: Screen: %dx%d (PinePhone portrait)\n",
           server->screen_width, server->screen_height);

    wl_display_run(server->display);
}

void n1_compositor_destroy(n1_server_t *server) {
    wl_display_destroy_clients(server->display);
    wlr_scene_node_destroy(&server->scene->tree.node);
    wlr_backend_destroy(server->backend);
    wl_display_destroy(server->display);
}
