import { acceptance } from 'helpers/qunit-helpers';

acceptance('Discourse Donations', {
  loggedIn: true,
  settings: {
    discourse_donations_enabled: true,
    discourse_donations_types: '',
    discourse_donations_amounts: '1',
  },
});

QUnit.test("donate page has a form on it", async assert => {
  await visit("/donate");
  assert.ok(exists(".donations-page-donations"));
});
