import RouteTemplate from "ember-route-template";
import bodyClass from "discourse/helpers/body-class";

export default RouteTemplate(
<template>
  {{bodyClass "user-billing-page"}}

  {{! The entire <section class="user-secondary-navigation"> has been removed }}

  <section class="user-content">
    {{outlet}}
  </section>
</template>
);
