import coreModelsTest from './CoreModels.test';
import dataAndSessionTest from './DataAndSession.test';

export default function testsuite(): void {
  coreModelsTest();
  dataAndSessionTest();
}
