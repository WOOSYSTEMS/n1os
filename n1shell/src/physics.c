/*
 * N1OS Shell — Physics engine
 * Spring dynamics, easing, momentum for card switcher
 */

#include "n1shell.h"

/* Damped spring simulation (critically damped for smooth UI) */
float n1_spring_update(float current, float target, float *velocity,
                       float stiffness, float damping, float dt) {
    float displacement = current - target;
    float spring_force = -stiffness * displacement;
    float damping_force = -damping * (*velocity);
    float acceleration = spring_force + damping_force;

    *velocity += acceleration * dt;
    float new_pos = current + (*velocity) * dt;

    /* Snap to target if close enough */
    if (fabsf(new_pos - target) < 0.5f && fabsf(*velocity) < 1.0f) {
        *velocity = 0.0f;
        return target;
    }

    return new_pos;
}

float n1_lerp(float a, float b, float t) {
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;
    return a + (b - a) * t;
}

/* Ease out cubic — fast start, gentle end */
float n1_ease_out_cubic(float t) {
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;
    float inv = 1.0f - t;
    return 1.0f - inv * inv * inv;
}

/* Ease out back — slight overshoot for playful tile animations */
float n1_ease_out_back(float t) {
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;
    const float c1 = 1.70158f;
    const float c3 = c1 + 1.0f;
    float inv = t - 1.0f;
    return 1.0f + c3 * inv * inv * inv + c1 * inv * inv;
}

/* Decelerate with friction (for scroll/fling) */
float n1_friction_decel(float velocity, float friction, float dt) {
    float sign = velocity > 0 ? 1.0f : -1.0f;
    float mag = fabsf(velocity);
    mag -= friction * dt;
    if (mag < 0.0f) mag = 0.0f;
    return sign * mag;
}
