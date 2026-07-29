import coreModelsTest from './CoreModels.test';
import dataAndSessionTest from './DataAndSession.test';
import feedbackPlanTest from './FeedbackPlan.test';

export default function testsuite(): void {
  coreModelsTest();
  dataAndSessionTest();
  feedbackPlanTest();
}
