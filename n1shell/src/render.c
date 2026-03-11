/*
 * N1OS Shell — Rendering
 * Cairo-based 2D rendering for home screen, tiles, clock, navbar, cards
 * GPU-accelerated via Lima (GLES2 texture upload)
 */

#include "n1shell.h"
#include <stdio.h>
#include <string.h>

/* ─── Rounded Rectangle Path ─── */

void n1_render_rounded_rect(cairo_t *cr, double x, double y,
                            double w, double h, double r) {
    cairo_new_sub_path(cr);
    cairo_arc(cr, x + w - r, y + r,     r, -M_PI/2, 0);
    cairo_arc(cr, x + w - r, y + h - r, r, 0,        M_PI/2);
    cairo_arc(cr, x + r,     y + h - r, r, M_PI/2,   M_PI);
    cairo_arc(cr, x + r,     y + r,     r, M_PI,     3*M_PI/2);
    cairo_close_path(cr);
}

/* ─── Clock + Date Header ─── */

void n1_render_clock(cairo_t *cr, int width) {
    time_t now = time(NULL);
    struct tm *tm = localtime(&now);
    char time_str[16], date_str[64];

    strftime(time_str, sizeof(time_str), "%H:%M", tm);
    strftime(date_str, sizeof(date_str), "%A, %B %d", tm);

    /* Time — large, lightweight */
    PangoLayout *layout = pango_cairo_create_layout(cr);
    PangoFontDescription *font;

    /* Big time */
    font = pango_font_description_from_string("Sans Light 52");
    pango_layout_set_font_description(layout, font);
    pango_layout_set_text(layout, time_str, -1);
    pango_font_description_free(font);

    int tw, th;
    pango_layout_get_pixel_size(layout, &tw, &th);

    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
    cairo_move_to(cr, N1_TILE_MARGIN, 20);
    pango_cairo_show_layout(cr, layout);

    /* Date — smaller, dimmer */
    font = pango_font_description_from_string("Sans Light 16");
    pango_layout_set_font_description(layout, font);
    pango_layout_set_text(layout, date_str, -1);
    pango_font_description_free(font);

    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 0.7);
    cairo_move_to(cr, N1_TILE_MARGIN, 20 + th + 4);
    pango_cairo_show_layout(cr, layout);

    g_object_unref(layout);
}

/* ─── Single Tile ─── */

void n1_render_tile(cairo_t *cr, n1_tile_t *tile, uint32_t theme_accent) {
    if (tile->anim_progress <= 0.0f) return;

    uint32_t color = tile->accent_color ? tile->accent_color : theme_accent;
    n1_color_t c = n1_color_from_hex(color, 1.0f);

    float prog = n1_ease_out_back(tile->anim_progress);

    cairo_save(cr);

    /* Animate from right with scale */
    float slide_x = (1.0f - prog) * 80.0f;
    float scale = 0.8f + 0.2f * prog;
    float alpha = prog;

    float cx = tile->x + tile->w / 2.0f;
    float cy = tile->y + tile->h / 2.0f;

    cairo_translate(cr, cx + slide_x, cy);
    cairo_scale(cr, scale, scale);
    cairo_translate(cr, -cx, -cy);

    /* Tile background */
    cairo_set_source_rgba(cr, c.r, c.g, c.b, alpha);
    n1_render_rounded_rect(cr, tile->x, tile->y, tile->w, tile->h, N1_TILE_CORNER);
    cairo_fill(cr);

    /* Flip animation — show live content on back */
    bool show_live = (tile->flip_progress > 0.5f) && tile->has_live_content;

    if (!show_live) {
        /* Front face — icon + name */
        PangoLayout *layout = pango_cairo_create_layout(cr);
        PangoFontDescription *font;

        /* Icon (emoji or text) */
        font = pango_font_description_from_string("Sans 24");
        pango_layout_set_font_description(layout, font);
        pango_layout_set_text(layout, tile->icon, -1);
        pango_font_description_free(font);

        cairo_set_source_rgba(cr, 1, 1, 1, alpha);
        cairo_move_to(cr, tile->x + 12, tile->y + 10);
        pango_cairo_show_layout(cr, layout);

        /* Name — bottom left */
        font = pango_font_description_from_string("Sans 13");
        pango_layout_set_font_description(layout, font);
        pango_layout_set_text(layout, tile->name, -1);
        pango_font_description_free(font);

        cairo_set_source_rgba(cr, 1, 1, 1, alpha * 0.9f);
        cairo_move_to(cr, tile->x + 12, tile->y + tile->h - 30);
        pango_cairo_show_layout(cr, layout);

        /* Notification badge */
        if (tile->live_count > 0) {
            char badge[8];
            snprintf(badge, sizeof(badge), "%d", tile->live_count);
            font = pango_font_description_from_string("Sans Bold 11");
            pango_layout_set_font_description(layout, font);
            pango_layout_set_text(layout, badge, -1);
            pango_font_description_free(font);

            int bw, bh;
            pango_layout_get_pixel_size(layout, &bw, &bh);

            cairo_set_source_rgba(cr, 1, 1, 1, alpha);
            cairo_move_to(cr, tile->x + tile->w - bw - 12, tile->y + 12);
            pango_cairo_show_layout(cr, layout);
        }

        g_object_unref(layout);
    } else {
        /* Back face — live content */
        PangoLayout *layout = pango_cairo_create_layout(cr);
        PangoFontDescription *font;

        font = pango_font_description_from_string("Sans 12");
        pango_layout_set_font_description(layout, font);
        pango_layout_set_text(layout, tile->live_text, -1);
        pango_layout_set_width(layout, (tile->w - 24) * PANGO_SCALE);
        pango_layout_set_wrap(layout, PANGO_WRAP_WORD);
        pango_font_description_free(font);

        cairo_set_source_rgba(cr, 1, 1, 1, alpha * 0.95f);
        cairo_move_to(cr, tile->x + 12, tile->y + 12);
        pango_cairo_show_layout(cr, layout);

        /* Name still at bottom */
        font = pango_font_description_from_string("Sans 11");
        pango_layout_set_font_description(layout, font);
        pango_layout_set_text(layout, tile->name, -1);
        pango_font_description_free(font);

        cairo_set_source_rgba(cr, 1, 1, 1, alpha * 0.6f);
        cairo_move_to(cr, tile->x + 12, tile->y + tile->h - 26);
        pango_cairo_show_layout(cr, layout);

        g_object_unref(layout);
    }

    cairo_restore(cr);
}

/* ─── Navigation Bar ─── */

void n1_render_navbar(cairo_t *cr, int width, int screen_height, uint32_t accent) {
    int y = screen_height - N1_NAVBAR_HEIGHT;
    n1_color_t ac = n1_color_from_hex(accent, 1.0f);

    /* Background */
    cairo_set_source_rgba(cr, 0.05, 0.05, 0.05, 0.95);
    cairo_rectangle(cr, 0, y, width, N1_NAVBAR_HEIGHT);
    cairo_fill(cr);

    /* Three buttons: ← ● ≡ */
    const char *buttons[] = {"◁", "●", "☰"};
    int btn_width = width / 3;

    PangoLayout *layout = pango_cairo_create_layout(cr);
    PangoFontDescription *font = pango_font_description_from_string("Sans 20");
    pango_layout_set_font_description(layout, font);

    for (int i = 0; i < 3; i++) {
        pango_layout_set_text(layout, buttons[i], -1);
        int tw, th;
        pango_layout_get_pixel_size(layout, &tw, &th);

        /* Center button (home) uses accent color */
        if (i == 1) {
            cairo_set_source_rgba(cr, ac.r, ac.g, ac.b, 1.0);
        } else {
            cairo_set_source_rgba(cr, 1, 1, 1, 0.6);
        }

        cairo_move_to(cr,
            i * btn_width + (btn_width - tw) / 2,
            y + (N1_NAVBAR_HEIGHT - th) / 2);
        pango_cairo_show_layout(cr, layout);
    }

    pango_font_description_free(font);
    g_object_unref(layout);
}

/* ─── App Switcher Card ─── */

void n1_render_card(cairo_t *cr, n1_card_t *card, int screen_w, int screen_h) {
    float card_w = screen_w * 0.85f;
    float card_h = screen_h * 0.7f;
    float card_x = (screen_w - card_w) / 2.0f + card->x_offset;
    float card_y = (screen_h - card_h) / 2.0f - 30;

    cairo_save(cr);
    cairo_scale(cr, card->scale, card->scale);

    /* Accent glow */
    n1_color_t glow = n1_color_from_hex(card->accent_color, 0.4f * card->opacity);
    cairo_set_source_rgba(cr, glow.r, glow.g, glow.b, glow.a);
    n1_render_rounded_rect(cr,
        card_x - N1_CARD_GLOW_SIZE,
        card_y - N1_CARD_GLOW_SIZE,
        card_w + N1_CARD_GLOW_SIZE * 2,
        card_h + N1_CARD_GLOW_SIZE * 2,
        N1_CARD_CORNER + N1_CARD_GLOW_SIZE);
    cairo_fill(cr);

    /* Card background */
    cairo_set_source_rgba(cr, 0.08, 0.08, 0.08, card->opacity);
    n1_render_rounded_rect(cr, card_x, card_y, card_w, card_h, N1_CARD_CORNER);
    cairo_fill(cr);

    /* App content would be composited here via wlr_scene */
    /* For now, render a placeholder */
    PangoLayout *layout = pango_cairo_create_layout(cr);
    PangoFontDescription *font = pango_font_description_from_string("Sans 14");
    pango_layout_set_font_description(layout, font);
    pango_layout_set_text(layout, "App Preview", -1);

    int tw, th;
    pango_layout_get_pixel_size(layout, &tw, &th);

    cairo_set_source_rgba(cr, 1, 1, 1, 0.5 * card->opacity);
    cairo_move_to(cr, card_x + (card_w - tw) / 2, card_y + (card_h - th) / 2);
    pango_cairo_show_layout(cr, layout);

    pango_font_description_free(font);
    g_object_unref(layout);

    cairo_restore(cr);
}
