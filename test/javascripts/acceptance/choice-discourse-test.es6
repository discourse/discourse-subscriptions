import { acceptance } from 'helpers/qunit-helpers';
acceptance('Choice Discourse', { loggedIn: true });

test('Choice Page Exists', () => {
  visit('/users/eviltrout/choice');

  andThen(() => {
    ok(exists('h1'), 'Choice');
    ok(exists('.payments'), 'eviltrout');
  });
});
