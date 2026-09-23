import { Router } from 'express';
import { createFeedFormulasRouter } from '../feed-formulas';
import { createFeedLogsRouter } from '../feed-logs';
import { createSpeechTherapyConsumptionRouter } from '../speech-therapy-consumption';
import { createTherapyExerciseImportAiExchangesRouter } from '../therapy-exercise-import-ai-exchanges';
import { createTherapyExerciseImportsRouter } from '../therapy-exercise-imports';
import { createTherapyExerciseLogsRouter } from '../therapy-exercise-logs';
import { createTherapyExercisesRouter } from '../therapy-exercises';

/**
 * Aggregates speech therapy data routers under /api/data.
 */
export const createSpeechTherapyDataService = (): Router => {
  const router = Router();
  router.use('/therapy-exercises', createTherapyExercisesRouter());
  router.use('/therapy-exercise-logs', createTherapyExerciseLogsRouter());
  router.use('/speech-therapy-consumption', createSpeechTherapyConsumptionRouter());
  router.use('/therapy-exercise-imports', createTherapyExerciseImportsRouter());
  router.use('/therapy-exercise-import-ai-exchanges', createTherapyExerciseImportAiExchangesRouter());
  router.use('/feed-formulas', createFeedFormulasRouter());
  router.use('/feed-logs', createFeedLogsRouter());
  return router;
};
