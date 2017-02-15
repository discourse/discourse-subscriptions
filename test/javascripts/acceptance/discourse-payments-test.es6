import { acceptance } from 'helpers/qunit-helpers';
acceptance('Discourse Payments', {
    loggedIn: true,
    setup() {
      const response = (object) => {
        return [
          200,
          {"Content-Type": "application/json"},
          object
        ];
      };

      server.post('/payments', () => {
        return response({ });
      });
    }
  }
);

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

  click('.payment-btn');

  andThen(() => {
    ok(exists('.payment-response'), 'Response happens');
  });
});
