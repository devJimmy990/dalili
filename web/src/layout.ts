/**
 * How the related-articles list is presented, by screen width.
 *
 *   desktop  a column beside the book, which stays visible
 *   tablet   a drawer sliding in from the side, over a dimmed page
 *   phone    a sheet rising from the bottom — the thumb's reach, and the full
 *            width a narrow screen needs to read a title
 */
export type LayoutMode = 'panel' | 'drawer' | 'sheet';

export const TABLET_MIN = 640;
export const DESKTOP_MIN = 1024;

export function layoutFor(width: number): LayoutMode {
  if (width >= DESKTOP_MIN) return 'panel';
  if (width >= TABLET_MIN) return 'drawer';
  return 'sheet';
}

/** Panel is part of the page; drawer and sheet float over it and trap focus. */
export const isModal = (mode: LayoutMode): boolean => mode !== 'panel';
