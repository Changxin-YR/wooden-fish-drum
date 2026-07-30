import coreModelsTest from './CoreModels.test';
import dataAndSessionTest from './DataAndSession.test';
import feedbackPlanTest from './FeedbackPlan.test';
import statsPeriodTest from './StatsPeriod.test';

export default function testsuite(): void {
  coreModelsTest();
  dataAndSessionTest();
  feedbackPlanTest();
  statsPeriodTest();
}
