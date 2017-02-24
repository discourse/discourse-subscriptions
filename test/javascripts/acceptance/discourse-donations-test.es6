import { acceptance } from 'helpers/qunit-helpers';
acceptance('Discourse Donations', { loggedIn: true });

test('Donations Link Exists', () => {
  visit('/users/eviltrout');

  andThen(() => {
    ok(exists('.discourse-donations > a'), 'Link exists on profile page');
  });
});
