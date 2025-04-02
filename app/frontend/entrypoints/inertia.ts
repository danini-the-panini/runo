import "~/stylesheets/application.css";

import { createInertiaApp, type ResolvedComponent } from "@inertiajs/svelte";
import { mount } from "svelte";

import ApplicationLayout from "../pages/layouts/Application.svelte";

createInertiaApp({
  resolve: (name = "Home") => {
    const pages = import.meta.glob<ResolvedComponent>("../pages/**/*.svelte", { eager: true });
    const page = pages[`../pages/${name}.svelte`];
    if (!page) {
      console.error(`Missing Inertia page component: '${name}.svelte'`);
    }

    return Object.assign({ layout: ApplicationLayout }, page);
  },

  setup({ el, App, props }) {
    if (el) {
      mount(App, { target: el, props });
    } else {
      console.error(
        'Missing root element.\n\n' +
          'If you see this error, it probably means you load Inertia.js on non-Inertia pages.\n' +
          'Consider moving <%= vite_typescript_tag "inertia" %> to the Inertia-specific layout instead.'
      );
    }
  }
});
