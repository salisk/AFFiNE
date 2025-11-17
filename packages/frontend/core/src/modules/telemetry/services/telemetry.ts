import { shallowEqual } from '@affine/component';
import { ServerDeploymentType } from '@affine/graphql';
import { mixpanel } from '@affine/track';
import { LiveData, OnEvent, Service } from '@toeverything/infra';

import type { AuthAccountInfo, Server, ServersService } from '../../cloud';
import type { GlobalContextService } from '../../global-context';
import { ApplicationStarted } from '../../lifecycle';

@OnEvent(ApplicationStarted, e => e.onApplicationStart)
export class TelemetryService extends Service {
  constructor(
    private readonly globalContextService: GlobalContextService,
    private readonly serversService: ServersService
  ) {
    super();
    // Telemetry disabled - no tracking
  }

  onApplicationStart() {
    // Telemetry disabled - no action needed
  }

  registerMiddlewares() {
    // Telemetry disabled - no middlewares registered
  }

  extractGlobalContext(): { page?: string; serverId?: string } {
    return {};
  }

  override dispose(): void {
    super.dispose();
  }
}
