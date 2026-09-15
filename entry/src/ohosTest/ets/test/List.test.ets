import coreModelsTest from './CoreModels.test';
import dataAndSessionTest from './DataAndSession.test';
import statsPeriodTest from './StatsPeriod.test';
import systemBarStyleTest from './SystemBarStyle.test';

export default function testsuite(): void {
  coreModelsTest();
  dataAndSessionTest();
  statsPeriodTest();
  systemBarStyleTest();
}
