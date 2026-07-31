import coreModelsTest from './CoreModels.test';
import dataAndSessionTest from './DataAndSession.test';
import feedbackPlanTest from './FeedbackPlan.test';
import migrationTest from './Migration.test';
import practiceRepositoryTest from './PracticeRepository.test';
import statsPeriodTest from './StatsPeriod.test';

export default function testsuite(): void {
  coreModelsTest();
  dataAndSessionTest();
  feedbackPlanTest();
  migrationTest();
  practiceRepositoryTest();
  statsPeriodTest();
}
