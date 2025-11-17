import * as Sentry from '@sentry/react';
import { useEffect } from 'react';
import {
  createRoutesFromChildren,
  matchRoutes,
  useLocation,
  useNavigationType,
} from 'react-router-dom';

function createSentry() {
  // Sentry disabled - all methods are no-ops
  const wrapped = {
    init() {
      // No-op: Sentry initialization disabled
    },
    enable() {
      // No-op: Sentry disabled
    },
    disable() {
      // No-op: Sentry disabled
    },
  };

  return wrapped;
}

export const sentry = createSentry();
