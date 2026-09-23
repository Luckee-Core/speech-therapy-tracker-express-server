import { Request, Response } from 'express';

/**
 * GET /api/health — liveness payload.
 */
export const getHealthHandler = (_req: Request, res: Response): void => {
  console.log('📥 GET /api/health');
  res.status(200).json({
    success: true,
    data: {
      status: 'ok',
      message: 'Speech Therapy Tracker Express Server is running',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
    },
  });
};
