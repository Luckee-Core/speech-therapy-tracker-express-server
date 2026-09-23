/**
 * Health Check Router
 * Provides endpoints for monitoring server health and status
 */

import { Router } from 'express';
import { getHealthHandler } from './routes/get-health-handler';

/**
 * Factory for health routes mounted at `/` and `/api/health`.
 */
export const createHealthRouter = (): Router => {
  const router = Router();

  /**
   * GET /
   * Basic health check endpoint
   */
  router.get('/', getHealthHandler);

  return router;
};
