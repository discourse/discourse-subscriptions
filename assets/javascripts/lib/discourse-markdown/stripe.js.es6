function validationErrors(tagInfo, content, siteSettings) {
    let errors = [];
    if (!siteSettings.discourse_donations_public_key) { errors.push("missing key (site setting)"); }
    if (!siteSettings.discourse_donations_currency) { errors.push("missing currency (site setting)"); }
    if (!siteSettings.discourse_donations_shop_name) { errors.push("missing name (site setting)"); }
    if (!siteSettings.discourse_donations_zip_code) { errors.push("missing zip code toggle (site setting)"); }
    if (!siteSettings.discourse_donations_billing_address) { errors.push("missing billing address toggle (site setting)"); }
    if (!tagInfo.attrs['amount']) { errors.push("missing amount"); }
    if (!content) { errors.push("missing description"); }
    return errors;
}

function replaceWithStripeOrError(siteSettings) {
    return function (state, tagInfo, content) {
        let errors = validationErrors(tagInfo, content, siteSettings);
        if (errors.length) {
            displayErrors(state, errors);
        } else {
            insertCheckout(state, tagInfo, content);
        }
        return true;
    };
}

function displayErrors(state, errors) {
    let token = state.push('div-open', 'div', 1);
    token.attrs = [['class', 'stripe-errors']];
    token = state.push('html_inline', '', 0);
    token.content = "Stripe checkout can't be rendered: " + errors.join(", ");
    state.push('div-close', 'div', -1);
}

function insertCheckout(state, tagInfo, content) {
    let token = state.push('stripe-checkout-form-open', 'form', 1);
    token.attrs = [
      ['method', 'POST'],
      ['action', '/checkout'],
      ['content', content],
      ['image', tagInfo.attrs['image']],
      ['class', 'stripe-checkout']
    ];

    token = state.push('stripe-checkout-form-amount', 'input', 0);
    token.attrs = [
      ['type', 'hidden'],
      ['name', 'amount'],
      ['value', tagInfo.attrs['amount']]
    ];

    state.push('stripe-checkout-form-close', 'form', -1);
}

function setupMarkdownIt(helper, siteSettings) {
    helper.registerPlugin(md => {
        md.inline.bbcode.ruler.push('stripe-checkout', {
            tag: 'stripe',
            replace: replaceWithStripeOrError(siteSettings)
        });
    });
}

export function setup(helper) {
    helper.registerOptions((opts,siteSettings)=>{
        helper.whiteList([
            'div[class]',
            'form[method]',
            'form[action]',
            'form[class]',
            'form[content]',
            'form[image]',
            'input[type]',
            'input[name]',
            'input[value]',
            'script[class]',
            'script[src]',
            'script[data-key]',
            'script[data-amount]',
            'script[data-name]',
            'script[data-description]',
            'script[data-image]',
            'script[data-zip-code]',
            'script[data-billing-address]',
            'script[data-currency]',
            'script[data-locale]'
        ]);
        if (helper.markdownIt) {
            setupMarkdownIt(helper, siteSettings);
        }
    });
}
