/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      typography: (theme) => ({
        DEFAULT: {
          css: {
            "ol,ul,li,p": {
              marginTop: "0",
              marginBottom: "0",
              paddingTop: "0",
              paddingBottom: "0",
            },
            li: {
              listStyleType: "inside",
            },
          },
        },
      }),
    },
  },
  plugins: [require("@tailwindcss/typography")],
};
