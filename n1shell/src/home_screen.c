/*
 * N1OS Shell — Home Screen
 * Metro/Lumia-style live tile grid with staggered boot animation
 */

#include "n1shell.h"
#include <stdio.h>

/* ─── Layout Tiles in Grid ─── */

void n1_home_layout(n1_server_t *server) {
    int avail_w = server->screen_width - 2 * N1_TILE_MARGIN;
    int col_w = (avail_w - N1_TILE_GAP) / N1_TILE_COLS;
    int row_h = col_w;  /* square base unit */

    int cur_row = 0;
    int cur_col = 0;
    int y_offset = N1_CLOCK_HEIGHT;

    for (int i = 0; i < server->tile_count; i++) {
        n1_tile_t *tile = &server->tiles[i];

        int span_cols, span_rows;
        switch (tile->size) {
            case TILE_SIZE_SMALL:
                span_cols = 1; span_rows = 1;
                break;
            case TILE_SIZE_MEDIUM:
                span_cols = 2; span_rows = 1;
                break;
            case TILE_SIZE_LARGE:
                span_cols = 2; span_rows = 2;
                break;
        }

        /* Wrap to next row if needed */
        if (cur_col + span_cols > N1_TILE_COLS) {
            cur_col = 0;
            cur_row++;
        }

        tile->grid_col = cur_col;
        tile->grid_row = cur_row;
        tile->x = N1_TILE_MARGIN + cur_col * (col_w + N1_TILE_GAP);
        tile->y = y_offset + cur_row * (row_h + N1_TILE_GAP);
        tile->w = span_cols * col_w + (span_cols - 1) * N1_TILE_GAP;
        tile->h = span_rows * row_h + (span_rows - 1) * N1_TILE_GAP;

        cur_col += span_cols;
        if (cur_col >= N1_TILE_COLS) {
            cur_col = 0;
            cur_row += span_rows;
        }
    }
}

void n1_home_init(n1_server_t *server) {
    n1_home_layout(server);
}

/* ─── Update Animations ─── */

void n1_home_update(n1_server_t *server, float dt) {
    int64_t now = n1_time_ms();

    for (int i = 0; i < server->tile_count; i++) {
        n1_tile_t *tile = &server->tiles[i];

        /* Boot stagger animation */
        if (server->home_boot_anim) {
            int64_t elapsed = now - server->boot_start_ms - tile->stagger_delay_ms;
            if (elapsed < 0) {
                tile->anim_progress = 0.0f;
            } else {
                float t = (float)elapsed / N1_TILE_ANIM_MS;
                if (t > 1.0f) t = 1.0f;
                tile->anim_progress = t;
            }
        }

        /* Live tile flip animation */
        if (tile->has_live_content && tile->anim_progress >= 1.0f) {
            if (!tile->is_flipping) {
                /* Check if it's time to flip */
                int64_t since_boot = now - server->boot_start_ms;
                /* Stagger flips across tiles */
                int64_t flip_offset = (i * 1700) + N1_FLIP_INTERVAL_MS;
                if (since_boot > flip_offset) {
                    int64_t cycle = (since_boot - flip_offset) % (N1_FLIP_INTERVAL_MS * 2);
                    if (cycle < N1_FLIP_DURATION_MS) {
                        tile->is_flipping = true;
                        tile->flip_start_ms = now;
                    }
                }
            }

            if (tile->is_flipping) {
                float flip_t = (float)(now - tile->flip_start_ms) / N1_FLIP_DURATION_MS;
                if (flip_t >= 1.0f) {
                    flip_t = 1.0f;
                    tile->is_flipping = false;
                    /* Toggle between front and back */
                    tile->flip_progress = tile->flip_progress < 0.5f ? 1.0f : 0.0f;
                } else {
                    /* Ease through flip */
                    float eased = n1_ease_out_cubic(flip_t);
                    tile->flip_progress = tile->flip_progress < 0.5f ? eased : 1.0f - eased;
                }
            }
        }
    }

    /* Check if boot animation is complete */
    if (server->home_boot_anim) {
        n1_tile_t *last = &server->tiles[server->tile_count - 1];
        if (last->anim_progress >= 1.0f) {
            server->home_boot_anim = false;
        }
    }

    /* Scroll momentum with friction */
    if (fabsf(server->home_scroll_vel) > 0.5f) {
        server->home_scroll_y += server->home_scroll_vel * dt;
        server->home_scroll_vel = n1_friction_decel(server->home_scroll_vel, 800.0f, dt);

        /* Clamp scroll */
        if (server->home_scroll_y < 0) {
            server->home_scroll_y = 0;
            server->home_scroll_vel = 0;
        }
        /* TODO: compute max scroll from tile layout */
    }
}

/* ─── Render Home Screen ─── */

void n1_home_render(n1_server_t *server, cairo_t *cr) {
    /* Black background */
    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_paint(cr);

    /* Apply scroll offset */
    cairo_save(cr);
    cairo_translate(cr, 0, -server->home_scroll_y);

    /* Clock + date */
    n1_render_clock(cr, server->screen_width);

    /* Tiles */
    for (int i = 0; i < server->tile_count; i++) {
        n1_render_tile(cr, &server->tiles[i], server->accent_color);
    }

    cairo_restore(cr);

    /* Navbar (fixed at bottom, not scrolled) */
    n1_render_navbar(cr, server->screen_width, server->screen_height,
                     server->accent_color);
}

/* ─── Touch Handling ─── */

/* event: 0=down, 1=motion, 2=up */
void n1_home_touch(n1_server_t *server, n1_touch_point_t *tp, int event) {
    switch (event) {
        case 0: /* Touch down */
            break;

        case 1: /* Motion — scroll */
            {
                float dy = tp->current_y - tp->start_y;
                if (fabsf(dy) > 10.0f) {
                    server->home_scroll_y -= (tp->current_y - tp->start_y) * 0.3f;
                    if (server->home_scroll_y < 0) server->home_scroll_y = 0;
                }
            }
            break;

        case 2: /* Touch up — check for tap */
            {
                float dx = tp->current_x - tp->start_x;
                float dy = tp->current_y - tp->start_y;
                float dist = sqrtf(dx * dx + dy * dy);

                if (dist < 15.0f) {
                    /* It's a tap — check navbar first */
                    int nav_y = server->screen_height - N1_NAVBAR_HEIGHT;
                    if (tp->start_y >= nav_y) {
                        int btn_w = server->screen_width / 3;
                        int btn_idx = (int)(tp->start_x / btn_w);
                        if (btn_idx == 0) {
                            /* Back button */
                        } else if (btn_idx == 1) {
                            /* Home button — already home */
                        } else if (btn_idx == 2) {
                            /* App switcher */
                            if (server->card_count > 0) {
                                n1_switcher_enter(server);
                            }
                        }
                    } else {
                        /* Tile tap */
                        int idx = n1_tile_hit_test(server, tp->start_x, tp->start_y);
                        if (idx >= 0) {
                            printf("N1: Launching %s: %s\n",
                                   server->tiles[idx].name,
                                   server->tiles[idx].exec_cmd);
                            /* TODO: Launch app via exec */
                        }
                    }
                } else {
                    /* It's a scroll fling */
                    server->home_scroll_vel = -tp->velocity_y;
                }
            }
            break;
    }
}

