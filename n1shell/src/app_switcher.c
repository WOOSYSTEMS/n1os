/*
 * N1OS Shell — App Switcher
 * Physics-based card flow with momentum, spring-back, and fling-to-dismiss
 */

#include "n1shell.h"
#include <stdio.h>

/* ─── Enter Switcher Mode ─── */

void n1_switcher_enter(n1_server_t *server) {
    server->mode = N1_MODE_SWITCHER;

    /* Snapshot open apps as cards */
    for (int i = 0; i < server->card_count; i++) {
        server->cards[i].x_offset = 0.0f;
        server->cards[i].x_velocity = 0.0f;
        server->cards[i].target_x = 0.0f;
        server->cards[i].scale = 0.85f;
        server->cards[i].opacity = 1.0f;
        server->cards[i].is_closing = false;

        /* Cycle accent colors for visual variety */
        static const uint32_t card_accents[] = {
            N1_ACCENT_BLUE, N1_ACCENT_PURPLE, N1_ACCENT_CYAN,
            N1_ACCENT_ORANGE, N1_ACCENT_PINK, N1_ACCENT_TEAL,
        };
        server->cards[i].accent_color = card_accents[i % 6];
    }

    /* Use theme accent for active card */
    if (server->card_count > 0) {
        server->cards[server->active_card_index].accent_color = server->accent_color;
    }

    printf("N1: Entered app switcher (%d cards)\n", server->card_count);
}

/* ─── Exit Switcher ─── */

void n1_switcher_exit(n1_server_t *server, int selected_index) {
    if (selected_index >= 0 && selected_index < server->card_count) {
        server->active_card_index = selected_index;
        server->active_toplevel = server->cards[selected_index].toplevel;
        server->mode = N1_MODE_APP;
        printf("N1: Switched to app %d\n", selected_index);
    } else {
        server->mode = N1_MODE_HOME;
    }
}

/* ─── Update Physics ─── */

void n1_switcher_update(n1_server_t *server, float dt) {
    for (int i = 0; i < server->card_count; i++) {
        n1_card_t *card = &server->cards[i];

        if (card->is_closing) {
            /* Flying out — accelerate off screen */
            card->x_offset += card->x_velocity * dt;
            card->opacity -= dt * 3.0f;
            if (card->opacity <= 0.0f) {
                /* Remove card */
                card->opacity = 0.0f;
                /* Shift remaining cards */
                for (int j = i; j < server->card_count - 1; j++) {
                    server->cards[j] = server->cards[j + 1];
                }
                server->card_count--;
                if (server->card_count == 0) {
                    n1_switcher_exit(server, -1);
                    return;
                }
                if (server->active_card_index >= server->card_count) {
                    server->active_card_index = server->card_count - 1;
                }
                i--; /* Recheck this index */
            }
        } else {
            /* Spring back to target position */
            float target = (i - server->active_card_index) *
                           (server->screen_width * 0.85f + N1_CARD_GAP);

            card->x_offset = n1_spring_update(
                card->x_offset, target + server->switcher_position,
                &card->x_velocity,
                N1_SPRING_STIFFNESS, N1_SPRING_DAMPING, dt);

            /* Scale: active card slightly larger */
            float dist = fabsf(card->x_offset);
            float target_scale = (dist < 50.0f) ? 0.9f : 0.82f;
            card->scale = n1_lerp(card->scale, target_scale, dt * 8.0f);
        }
    }
}

/* ─── Render ─── */

void n1_switcher_render(n1_server_t *server, cairo_t *cr) {
    /* Dark background with slight vignette */
    cairo_set_source_rgb(cr, 0.02, 0.02, 0.02);
    cairo_paint(cr);

    /* Render cards back-to-front (furthest first) */
    for (int i = 0; i < server->card_count; i++) {
        n1_render_card(cr, &server->cards[i],
                       server->screen_width, server->screen_height);
    }

    /* Dot indicators at bottom */
    if (server->card_count > 1) {
        int dot_size = 8;
        int dot_gap = 16;
        int total_w = server->card_count * dot_size +
                      (server->card_count - 1) * dot_gap;
        int dot_x = (server->screen_width - total_w) / 2;
        int dot_y = server->screen_height - 40;

        for (int i = 0; i < server->card_count; i++) {
            float alpha = (i == server->active_card_index) ? 1.0f : 0.3f;
            n1_color_t ac = n1_color_from_hex(server->accent_color, alpha);
            cairo_set_source_rgba(cr, ac.r, ac.g, ac.b, ac.a);
            cairo_arc(cr, dot_x + i * (dot_size + dot_gap) + dot_size / 2,
                      dot_y, dot_size / 2, 0, 2 * M_PI);
            cairo_fill(cr);
        }
    }
}

/* ─── Touch ─── */

/* event: 0=down, 1=motion, 2=up */
void n1_switcher_touch(n1_server_t *server, n1_touch_point_t *tp, int event) {
    switch (event) {
        case 0: /* Touch down */
            server->switcher_position = 0;
            break;

        case 1: /* Motion — drag cards horizontally */
            {
                float dx = tp->current_x - tp->start_x;
                server->switcher_position = dx;
            }
            break;

        case 2: /* Touch up — fling or spring back */
            {
                float dx = tp->current_x - tp->start_x;
                float vx = tp->velocity_x;

                if (fabsf(vx) > N1_FLING_THRESHOLD) {
                    /* Fling to dismiss current card */
                    int idx = server->active_card_index;
                    if (idx >= 0 && idx < server->card_count) {
                        server->cards[idx].is_closing = true;
                        server->cards[idx].x_velocity = vx * 2.0f;
                        printf("N1: Flung card %d (v=%.0f)\n", idx, vx);
                    }
                } else if (fabsf(dx) > server->screen_width * 0.3f) {
                    /* Swiped far enough to switch cards */
                    if (dx < 0 && server->active_card_index < server->card_count - 1) {
                        server->active_card_index++;
                    } else if (dx > 0 && server->active_card_index > 0) {
                        server->active_card_index--;
                    }
                } else if (fabsf(dx) < 15.0f) {
                    /* Tap — select this card */
                    n1_switcher_exit(server, server->active_card_index);
                }
                /* Spring back */
                server->switcher_position = 0;
            }
            break;
    }
}
