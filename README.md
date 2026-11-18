# AgusQuartz portfolio

Static portfolio published with GitHub Pages from the repository root. `index.html` is and will remain the main Spanish page.

## Languages

The language selector links to separate HTML documents: `/` (Spanish), `/en/`, `/pt/`, `/zh-hant/`, `/ru/`, and `/de/`. Language pages are generated in their respective folders (`en/index.html`, `pt/index.html`, and so on). They do not require Cloudflare, server functions, or redirects.

After editing `src/portfolio.template.html` or the text in `locales/`, regenerate the pages with:

```sh
node scripts/build-portfolio.mjs
```

The script writes the Spanish homepage to `index.html` and the other language versions to their folders. Generated HTML files are included in the repository, so GitHub Pages serves them after a push without running the generator in production. For local development, run `python3 -m http.server 8000` and open `http://localhost:8000/`.

Project links use paths from the domain root, such as `/academic-progress/`, so they work from both `/` and `/en/`.

## SYSMAN and Image Service

The portfolio presents SYSMAN as a product in real-world use since 2024, built and evolved alongside merchants. The team observes how merchants use each version and considers their feedback when deciding which improvements to make. The portfolio describes its single-tenant architecture without exposing product screens or workflows; interested companies are invited to discuss their needs.

Image Service is presented as an open-source Rust service used in production by SYSMAN, with a link to [its repository](https://github.com/agusquartz/image_service).
