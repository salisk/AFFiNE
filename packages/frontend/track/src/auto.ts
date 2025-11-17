import { DebugLogger } from '@affine/debug';

import type { CallableEventsChain, EventsUnion } from './types';

const logger = new DebugLogger('mixpanel');

interface TrackFn {
  (event: string, props: Record<string, any>): void;
}

const levels = ['page', 'segment', 'module', 'event'] as const;
export function makeTracker(trackFn: TrackFn): CallableEventsChain {
  function makeTrackerInner(level: number, info: Record<string, string>) {
    const proxy = new Proxy({} as Record<string, any>, {
      get(target, prop) {
        if (
          typeof prop !== 'string' ||
          prop === '$$typeof' /* webpack hot-reload reads this prop */
        ) {
          return undefined;
        }

        if (levels[level] === 'event') {
          return (arg: string | Record<string, any>) => {
            trackFn(prop, {
              ...info,
              ...(typeof arg === 'string' ? { arg } : arg),
            });
          };
        } else {
          let levelProxy = target[prop];
          if (levelProxy) {
            return levelProxy;
          }

          levelProxy = makeTrackerInner(
            level + 1,
            prop === '$' ? { ...info } : { ...info, [levels[level]]: prop }
          );
          target[prop] = levelProxy;
          return levelProxy;
        }
      },
    });

    return proxy;
  }

  return makeTrackerInner(0, {}) as CallableEventsChain;
}

/**
 * listen on clicking on all subtree elements and auto track events if defined
 *
 * @example
 *
 * ```html
 * <button
 *   data-event-chain='$.cmdk.settings.changeLanguage'
 *   data-event-arg='cn'
 *   <!-- or -->
 *   data-event-args-foo='bar'
 * />
 * ```
 */
export function enableAutoTrack(root: HTMLElement, trackFn: TrackFn) {
  // Auto-tracking disabled - return no-op cleanup function
  return () => {};
}

declare module 'react' {
  //  we have to declare `T` but it's actually not used
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  interface HTMLAttributes<T> {
    'data-event-props'?: EventsUnion;
    'data-event-arg'?: string;
    'data-event-args-control'?: string;
  }
}
