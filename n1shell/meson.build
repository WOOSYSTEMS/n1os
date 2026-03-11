project('n1shell', 'c',
  version: '1.0.0',
  default_options: [
    'c_std=c11',
    'warning_level=1',
    'optimization=2',
  ],
)

add_project_arguments('-DWLR_USE_UNSTABLE', language: 'c')

# Generate xdg-shell protocol header
wayland_scanner = find_program('wayland-scanner')
wayland_protocols = dependency('wayland-protocols')
wl_protocol_dir = wayland_protocols.get_variable('pkgdatadir')

xdg_shell_xml = wl_protocol_dir / 'stable/xdg-shell/xdg-shell.xml'
xdg_shell_h = custom_target('xdg-shell-protocol-header',
  input: xdg_shell_xml,
  output: 'xdg-shell-protocol.h',
  command: [wayland_scanner, 'server-header', '@INPUT@', '@OUTPUT@'],
)

# Dependencies
wayland_server = dependency('wayland-server')
wlroots = dependency('wlroots-0.18')
xkbcommon = dependency('xkbcommon')
cairo = dependency('cairo')
pango = dependency('pango')
pangocairo = dependency('pangocairo')
glesv2 = dependency('glesv2')
egl = dependency('egl')
libinput = dependency('libinput')
math = meson.get_compiler('c').find_library('m')

n1shell_src = files(
  'src/main.c',
  'src/compositor.c',
  'src/home_screen.c',
  'src/app_switcher.c',
  'src/render.c',
  'src/input.c',
  'src/tile.c',
  'src/physics.c',
  'src/config.c',
)

executable('n1shell',
  n1shell_src,
  xdg_shell_h,
  dependencies: [
    wayland_server,
    wlroots,
    xkbcommon,
    cairo,
    pango,
    pangocairo,
    glesv2,
    egl,
    libinput,
    math,
  ],
  install: true,
)
