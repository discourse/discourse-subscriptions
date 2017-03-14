import { acceptance } from 'helpers/qunit-helpers';
acceptance('Discourse Donations', { loggedIn: true });

test('Donations Link Exists', () => {
  visit('/');

  andThen(() => {
    ok(exists('.list-controls .donate a'), 'Link exists on profile page');
  });
});
