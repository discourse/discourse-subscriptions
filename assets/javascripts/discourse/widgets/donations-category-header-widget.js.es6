import { createWidget } from 'discourse/widgets/widget';
import { h } from 'virtual-dom';
import { avatarFor }  from 'discourse/widgets/post';
import { userPath } from "discourse/lib/url";
import { iconNode } from "discourse-common/lib/icon-library";

function donationDisplay(amount, type) {
  return h(`div.donations-${type}`, [
    h('span', I18n.t(`discourse_donations.cause.category.${type}`)),
    h('span', `$${(amount/100).toFixed(2)}`)
  ]);
}

createWidget('category-header-widget', {
  tagName: 'span',

  html(args) {

    const controller = this.register.lookup('controller:navigation/category');
    const category = controller.get("category");

    if (args.currentPath.toLowerCase().indexOf('category') > -1 &&
        category &&
        category.donations_cause) {
      $("body").addClass("donations-category");

      let contents = [
        h('div.donations-category-contents', [
          h('h1', category.name),
          h('div.category-title-description', h('p', category.description_text))
        ])
      ];

      let metadata = [];

      if (category.donations_total !== undefined) {
        metadata.push(donationDisplay(category.donations_total || 0, 'total'));

        if (Discourse.SiteSettings.discourse_donations_cause_month) {
          metadata.push(donationDisplay(category.donations_month || 0, 'month'));
        }
      }

      if (category.donations_github) {
        metadata.push(
          h('div.donations-github', this.attach('link', {
            icon: 'github',
            label: 'discourse_donations.cause.github.label',
            href: category.donations_github
          }))
        );
      }

      if (category.donations_meta) {
        metadata.push(
          h('div.donations-meta', this.attach('link', {
            href: category.donations_meta,
            contents: () => {
              return [
                h('img.meta-icon', {
                  attributes: {
                    src: 'https://discourse-meta.s3.dualstack.us-west-1.amazonaws.com/original/3X/b/1/b19ba793155a785bbd9707bc0cabbd3a987fa126.png?v=6'
                  }
                }),
                h('span', I18n.t('discourse_donations.cause.meta.label'))
              ];
            }
          }))
        );
      }

      if (category.donations_release_oldest) {
        let releaseArray = category.donations_release_oldest.split('/');
        let label = releaseArray[releaseArray.length - 1];
        metadata.push(
          h('div.donations-release-oldest', [
            h('span', '>'),
            this.attach('link', {
              href: category.donations_release_oldest,
              icon: 'tag',
              rawLabel: label,
              omitSpan: true,
              attributes: {
                target: '_blank'
              }
            })
          ])
        )
      }

      if (category.donations_release_latest) {
        let releaseArray = category.donations_release_latest.split('/');
        let label = releaseArray[releaseArray.length - 1];
        metadata.push(
          h('div.donations-release-latest', [
            h('span', '<'),
            this.attach('link', {
              href: category.donations_release_latest,
              icon: 'tag',
              rawLabel: label,
              omitSpan: true,
              attributes: {
                target: '_blank'
              }
            })
          ])
        )
      }

      if (metadata.length) {
        contents.push(h('div.donations-category-metadata', metadata));
      }

      let users = [];

      if (category.donations_backers.length) {
        users.push(h('div.donations-backers', [
          h('div.donations-backers-title', I18n.t('discourse_donations.cause.backers.label')),
          category.donations_backers.map(user => {
            if (user) {
              return avatarFor('medium', {
                template: user.avatar_template,
                username: user.username,
                name: user.name,
                url: userPath(user.username),
                className: "backer-avatar"
              });
            } else {
              return;
            }
          })
        ]));
      };

      if (category.donations_maintainers.length) {
        let maintainersLabel = category.donations_maintainers_label ||
          I18n.t('discourse_donations.cause.maintainers.label');

        users.push(h('div.donations-maintainers', [
          h('div.donations-maintainers-title', maintainersLabel),
          category.donations_maintainers.map(user => {
            if (user) {
              return avatarFor('medium', {
                template: user.avatar_template,
                username: user.username,
                name: user.name,
                url: userPath(user.username),
                className: "maintainer-avatar"
              });
            } else {
              return;
            }
          })
        ]));
      }

      if (users.length) {
        contents.push(h('div.donations-category-users', users));
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
