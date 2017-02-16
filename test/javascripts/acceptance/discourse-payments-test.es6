import { acceptance } from 'helpers/qunit-helpers';
acceptance('Discourse Payments', { loggedIn: true });

test('Payments Link Exists', () => {
  visit('/users/eviltrout');

  andThen(() => {
    ok(exists('.discourse-payments > a'), 'Link exists on profile page');
  });
});
