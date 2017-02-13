import { acceptance } from 'helpers/qunit-helpers';
acceptance('Choice Discourse', { loggedIn: true });

test('Choice Page Exists', () => {
  visit('/users/eviltrout/choice');

  andThen(() => {
    ok(exists('h1'), 'Heading exists');
    ok($.trim($('.payments').text()) == 'eviltrout', 'username is present on page');
  });
});

test('Choice Page response happens', () => {
  visit('/users/eviltrout/choice');

  click('.choice-btn');

  andThen(() => {
    ok(exists('.choice-response'), 'Response happens');
  });
});
