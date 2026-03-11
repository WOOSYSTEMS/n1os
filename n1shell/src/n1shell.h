/*
 * N1OS Shell — Custom Wayland compositor
 * Metro/Lumia-inspired home screen + physics card app switcher
 * WOOSystems 2026
 */

#ifndef N1SHELL_H
#define N1SHELL_H

#define _POSIX_C_SOURCE 200809L
#define _GNU_SOURCE

#include <wayland-server-core.h>
#include <wlr/backend.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/render/allocator.h>
#include <wlr/types/wlr_output.h>
#include <wlr/types/wlr_output_layout.h>
#include <wlr/types/wlr_scene.h>
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/types/wlr_cursor.h>
#include <wlr/types/wlr_seat.h>
#include <wlr/types/wlr_input_device.h>
#include <wlr/types/wlr_keyboard.h>
#include <wlr/types/wlr_pointer.h>
#include <wlr/types/wlr_touch.h>
#include <wlr/util/log.h>
#include <cairo/cairo.h>
#include <pango/pangocairo.h>
#include <math.h>
#include <time.h>
#include <stdbool.h>

/* ─── Theme / Accent Colors ─── */

#define N1_DEFAULT_ACCENT    0x00c853  /* N1OS Green */
#define N1_ACCENT_BLUE       0x2979ff
#define N1_ACCENT_RED        0xff1744
#define N1_ACCENT_PURPLE     0xd500f9
#define N1_ACCENT_ORANGE     0xff9100
#define N1_ACCENT_CYAN       0x00e5ff
#define N1_ACCENT_PINK       0xf50057
#define N1_ACCENT_YELLOW     0xffd600
#define N1_ACCENT_TEAL       0x1de9b6

#define N1_BG_COLOR          0x000000  /* Pure black background */
#define N1_TEXT_COLOR         0xffffff
#define N1_TEXT_DIM           0x888888

/* ─── Layout Constants ─── */

#define N1_TILE_COLS         2
#define N1_TILE_GAP          8       /* px between tiles */
#define N1_TILE_MARGIN       16      /* px screen edge margin */
#define N1_CLOCK_HEIGHT      140     /* px for time+date header */
#define N1_NAVBAR_HEIGHT     56      /* px bottom navigation bar */
#define N1_TILE_CORNER       4       /* px corner radius */

/* ─── Animation ─── */

#define N1_ANIM_FPS          60
#define N1_TILE_STAGGER_MS   50      /* ms delay between tile animations */
#define N1_TILE_ANIM_MS      300     /* ms for tile slide-in */
#define N1_FLIP_INTERVAL_MS  5000    /* ms between live tile flips */
#define N1_FLIP_DURATION_MS  400     /* ms for flip animation */

/* ─── Physics (App Switcher) ─── */

#define N1_SPRING_STIFFNESS  300.0f
#define N1_SPRING_DAMPING    25.0f
#define N1_FLING_THRESHOLD   400.0f  /* px/s velocity to dismiss card */
#define N1_CARD_GAP          20      /* px between cards */
#define N1_CARD_CORNER       16      /* px corner radius */
#define N1_CARD_GLOW_SIZE    4       /* px accent glow around card */

/* ─── Max Limits ─── */

#define N1_MAX_TILES         32
#define N1_MAX_VIEWS         16
#define N1_MAX_TOUCH_POINTS  10

/* ─── Data Types ─── */

typedef struct n1_color {
    float r, g, b, a;
} n1_color_t;

static inline n1_color_t n1_color_from_hex(uint32_t hex, float alpha) {
    return (n1_color_t){
        .r = ((hex >> 16) & 0xFF) / 255.0f,
        .g = ((hex >> 8) & 0xFF) / 255.0f,
        .b = (hex & 0xFF) / 255.0f,
        .a = alpha,
    };
}

/* ─── Tile Definition ─── */

typedef enum {
    TILE_SIZE_SMALL,    /* 1x1 */
    TILE_SIZE_MEDIUM,   /* 2x1 (wide) */
    TILE_SIZE_LARGE,    /* 2x2 */
} n1_tile_size_t;

typedef struct n1_tile {
    char name[64];
    char icon[128];          /* icon path or emoji */
    char exec_cmd[256];      /* command to launch */
    n1_tile_size_t size;
    uint32_t accent_color;   /* per-tile accent override, 0 = use theme */

    /* Live tile content */
    bool has_live_content;
    char live_text[256];
    int live_count;          /* notification count */

    /* Animation state */
    float anim_progress;     /* 0.0 = hidden, 1.0 = fully visible */
    float flip_progress;     /* 0.0 = front, 1.0 = back (live content) */
    bool is_flipping;
    int64_t flip_start_ms;
    int64_t stagger_delay_ms;

    /* Layout (computed) */
    int grid_col, grid_row;
    int x, y, w, h;         /* screen coordinates */
} n1_tile_t;

/* ─── App Card (Switcher) ─── */

typedef struct n1_card {
    struct wlr_xdg_toplevel *toplevel;
    struct wlr_scene_tree *scene_tree;

    /* Physics state */
    float x_offset;        /* current horizontal displacement */
    float x_velocity;       /* px/s */
    float target_x;         /* spring target */
    float scale;            /* card scale (0.85 in switcher) */
    float opacity;

    /* Glow */
    uint32_t accent_color;

    bool is_closing;        /* flying out */
} n1_card_t;

/* ─── Touch State ─── */

typedef struct n1_touch_point {
    int32_t id;
    double start_x, start_y;
    double current_x, current_y;
    double velocity_x, velocity_y;
    int64_t start_time_ms;
    int64_t last_time_ms;
    bool active;
} n1_touch_point_t;

/* ─── Shell State ─── */

typedef enum {
    N1_MODE_HOME,          /* Metro tile home screen */
    N1_MODE_APP,           /* Full-screen app view */
    N1_MODE_SWITCHER,      /* Card flow app switcher */
} n1_shell_mode_t;

typedef struct n1_server {
    /* Wayland core */
    struct wl_display *display;
    struct wlr_backend *backend;
    struct wlr_renderer *renderer;
    struct wlr_allocator *allocator;
    struct wlr_output_layout *output_layout;
    struct wlr_scene *scene;
    struct wlr_scene_output_layout *scene_layout;

    /* XDG shell */
    struct wlr_xdg_shell *xdg_shell;
    struct wl_listener new_xdg_toplevel;
    struct wl_listener new_xdg_popup;

    /* Input */
    struct wlr_seat *seat;
    struct wlr_cursor *cursor;
    struct wl_listener new_input;
    n1_touch_point_t touches[N1_MAX_TOUCH_POINTS];

    /* Output */
    struct wl_list outputs;
    struct wl_listener new_output;
    int screen_width, screen_height;

    /* Shell state */
    n1_shell_mode_t mode;
    uint32_t accent_color;

    /* Home screen */
    n1_tile_t tiles[N1_MAX_TILES];
    int tile_count;
    float home_scroll_y;      /* vertical scroll offset */
    float home_scroll_vel;
    bool home_boot_anim;      /* true during boot stagger */
    int64_t boot_start_ms;

    /* App switcher */
    n1_card_t cards[N1_MAX_VIEWS];
    int card_count;
    int active_card_index;
    float switcher_position;   /* horizontal scroll position */

    /* Active app */
    struct wlr_xdg_toplevel *active_toplevel;

    /* Timer */
    struct wl_event_source *frame_timer;
    int64_t last_frame_ms;
} n1_server_t;

/* ─── Function Declarations ─── */

/* compositor.c */
int  n1_compositor_init(n1_server_t *server);
void n1_compositor_run(n1_server_t *server);
void n1_compositor_destroy(n1_server_t *server);

/* home_screen.c */
void n1_home_init(n1_server_t *server);
void n1_home_layout(n1_server_t *server);
void n1_home_update(n1_server_t *server, float dt);
void n1_home_render(n1_server_t *server, cairo_t *cr);
void n1_home_touch(n1_server_t *server, n1_touch_point_t *tp, int event);

/* app_switcher.c */
void n1_switcher_enter(n1_server_t *server);
void n1_switcher_exit(n1_server_t *server, int selected_index);
void n1_switcher_update(n1_server_t *server, float dt);
void n1_switcher_render(n1_server_t *server, cairo_t *cr);
void n1_switcher_touch(n1_server_t *server, n1_touch_point_t *tp, int event);

/* render.c */
void n1_render_init(n1_server_t *server);
void n1_render_frame(n1_server_t *server);
void n1_render_rounded_rect(cairo_t *cr, double x, double y, double w, double h, double r);
void n1_render_tile(cairo_t *cr, n1_tile_t *tile, uint32_t theme_accent);
void n1_render_clock(cairo_t *cr, int width);
void n1_render_navbar(cairo_t *cr, int width, int screen_height, uint32_t accent);
void n1_render_card(cairo_t *cr, n1_card_t *card, int screen_w, int screen_h);

/* input.c */
void n1_input_init(n1_server_t *server);
void n1_input_handle_touch_down(n1_server_t *server, int32_t id, double x, double y);
void n1_input_handle_touch_up(n1_server_t *server, int32_t id);
void n1_input_handle_touch_motion(n1_server_t *server, int32_t id, double x, double y);

/* tile.c */
void n1_tiles_load_defaults(n1_server_t *server);
int  n1_tile_hit_test(n1_server_t *server, double x, double y);

/* physics.c */
float n1_spring_update(float current, float target, float *velocity, float stiffness, float damping, float dt);
float n1_lerp(float a, float b, float t);
float n1_ease_out_cubic(float t);
float n1_ease_out_back(float t);
float n1_friction_decel(float velocity, float friction, float dt);

/* config.c */
void n1_config_load(n1_server_t *server);
void n1_config_save(n1_server_t *server);

/* Utility */
int64_t n1_time_ms(void);

#endif /* N1SHELL_H */
