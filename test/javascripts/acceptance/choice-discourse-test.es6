import { acceptance } from 'helpers/qunit-helpers';
acceptance('Discourse Payments', { loggedIn: true });

test('Payments Link Exists', () => {
  visit('/users/eviltrout');

  andThen(() => {
    ok(exists('.discourse-payments > a'), 'Link exists on profile page');
  });
});

test('Payments Page Exists', () => {
  visit('/users/eviltrout/payments');

  andThen(() => {
    ok(exists('h1'), 'Heading exists');
    ok($.trim($('.payments').text()) == 'eviltrout', 'username is present on page');
  });
});

test('Payments Page response happens', () => {
  visit('/users/eviltrout/payments');

  click('.choice-btn');

  andThen(() => {
    ok(exists('.choice-response'), 'Response happens');
  });
});
