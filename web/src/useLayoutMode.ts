import { useEffect, useState } from 'react';
import { DESKTOP_MIN, TABLET_MIN, layoutFor, type LayoutMode } from './layout';

/** The current [LayoutMode], following the window as it is resized or rotated. */
export function useLayoutMode(): LayoutMode {
  const [mode, setMode] = useState<LayoutMode>(() => layoutFor(window.innerWidth));

  useEffect(() => {
    // Listen to the two breakpoints themselves rather than every resize event.
    const queries = [TABLET_MIN, DESKTOP_MIN].map((min) => window.matchMedia(`(min-width: ${min}px)`));
    const update = () => setMode(layoutFor(window.innerWidth));

    queries.forEach((query) => query.addEventListener('change', update));
    update();
    return () => queries.forEach((query) => query.removeEventListener('change', update));
  }, []);

  return mode;
}
