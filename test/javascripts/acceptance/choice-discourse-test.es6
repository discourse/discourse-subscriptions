import { acceptance } from 'helpers/qunit-helpers';
acceptance('Choice Discourse', { loggedIn: true });

test('Choice Page Exists', () => {
  visit('/users/eviltrout/choice');

  andThen(() => {
    ok(exists('h1'), 'Heading exists');
    ok($.trim($('.payments').text()) == 'eviltrout', 'eviltrout');
  });
});
