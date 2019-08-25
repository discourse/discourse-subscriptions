import { acceptance } from 'helpers/qunit-helpers';

acceptance('Discourse Donations', {
  loggedIn: true,
  settings: {},
});

test('test runs without a crash', (assert) => {
  visit('/');
  assert.ok(true, 'test runs');
});
