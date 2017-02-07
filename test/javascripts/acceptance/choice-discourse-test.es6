import { acceptance } from 'helpers/qunit-helpers';
acceptance('Choice Discourse', { loggedIn: true });

test('Choice Page Exists', () => {
  visit('/choice/form');

  andThen(() => {
    ok(exists('h1'), 'Choice');
    ok(exists('form'), 'Something');
  });
});
