import { enableAutoTrack, makeTracker } from './auto';
import { type EventArgs, type Events } from './events';
import { mixpanel } from './mixpanel';
import { sentry } from './sentry';
export const track = makeTracker((event, props) => {
  // Telemetry disabled - no event tracking
});

export { enableAutoTrack, type EventArgs, type Events, mixpanel, sentry };
export default track;
