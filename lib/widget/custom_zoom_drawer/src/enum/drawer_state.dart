/// Drawer state enum.
///
/// Note: upon drawer dragging the state is always opening.
/// Use [DrawerLastAction] to figure if last state was either opened or closed.
enum DrawerState {
  /// Drawer is opening.
  opening,

  /// Drawer is closing.
  closing,

  /// Drawer is open.
  open,

  /// Drawer is closed.
  closed,
}
