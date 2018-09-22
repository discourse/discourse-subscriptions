import { createWidget } from 'discourse/widgets/widget';
import { h } from 'virtual-dom';
import { avatarFor }  from 'discourse/widgets/post';

function donationDisplay(amount, type) {
  return h(`div.donations-${type}`, [
    h('span', I18n.t(`discourse_donations.cause.category.${type}`)),
    h('span', `$${(amount/100).toFixed(2)}`)
  ]);
}

createWidget('category-header-widget', {
  tagName: 'span',

  html() {
    let category;

    const controller = this.container.lookup('controller:navigation/category');
    category = controller.get("category");

    if(category && category.donations_cause) {
      $("body").addClass("donations-category");

      let contents = [
        h('div.donations-category-contents', [
          h('h1', category.name),
          h('div.category-title-description', h('p', category.description_text))
        ]),
        h('div.donations-category-metadata', [
          donationDisplay(category.donations_total || 0, 'total'),
          donationDisplay(category.donations_month || 0, 'month'),
          h('div.donations-github', this.attach('link', {
            icon: 'github',
            label: 'discourse_donations.cause.github.label',
            href: category.donations_github
          }))
        ])
      ];

      let userContents = [];

      if (category.donations_backers.length) {
        userContents.push(h('div.donations-backers', [
          h('div.donations-backers-title', I18n.t('discourse_donations.cause.backers.label')),
          category.donations_backers.map(user => {
            return avatarFor('medium', {
              template: user.avatar_template,
              username: user.username,
              name: user.name,
              url: user.usernameUrl,
              className: "backer-avatar"
            });
          })
        ]));
      };

      if (category.donations_maintainers.length) {
        userContents.push(h('div.donations-maintainers', [
          h('div.donations-maintainers-title', I18n.t('discourse_donations.cause.maintainers.label')),
          category.donations_maintainers.map(user => {
            if (user) {
              return avatarFor('medium', {
                template: user.avatar_template,
                username: user.username,
                name: user.name,
                url: user.usernameUrl,
                className: "maintainer-avatar"
              });
            } else {
              return;
            }
          })
        ]));
      }

      if (userContents.length) {
        contents.push(h('div.donations-category-users', userContents));
      }

      return h('div.donations-category-header', {
        "attributes" : {
          "style" : "background-color: #" + category.color + "; color: #" + category.text_color + ";"
        }
      }, contents);
    } else {
      $("body").removeClass("donations-category");
    }
  }
});
