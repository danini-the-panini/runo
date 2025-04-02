import { svelte } from '@sveltejs/vite-plugin-svelte'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";

export default defineConfig({
  resolve: {
    dedupe: ["axios"]
  },
  plugins: [
    svelte(),
    tailwindcss(),
    RubyPlugin()
  ]
});
