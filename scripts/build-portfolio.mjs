import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.cwd();
const sourcePath = path.join(root, "index.html");
const source = await readFile(path.join(root, "src/portfolio.template.html"), "utf8");
const localePaths = {
  es: "/",
  en: "/en/",
  pt: "/pt/",
  "zh-Hant": "/zh-hant/",
  ru: "/ru/",
  de: "/de/",
};
const documentLocales = { es: "es", en: "en", pt: "pt-BR", "zh-Hant": "zh-Hant", ru: "ru", de: "de" };
const languageNames = { es: "Español", en: "English", pt: "Português", "zh-Hant": "繁體中文", ru: "Русский", de: "Deutsch" };
const languageCodes = { es: "ES", en: "EN", pt: "PT", "zh-Hant": "繁中", ru: "RU", de: "DE" };
const locales = {};
for (const locale of Object.keys(localePaths)) {
  locales[locale] = JSON.parse(await readFile(path.join(root, `locales/${locale}.json`), "utf8"));
}

function get(messages, key) {
  return key.split(".").reduce((value, part) => value?.[part], messages);
}

function escapeHtml(value) {
  return String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function replaceLocalizedContent(html, attr, messages, allowMarkup = false) {
  const pattern = new RegExp(`<([a-zA-Z][\\w:-]*)([^>]*\\b${attr}="([^"]+)"[^>]*)>([\\s\\S]*?)<\\/\\1>`, "g");
  return html.replace(pattern, (whole, tag, attributes, key) => {
    const value = get(messages, key);
    if (typeof value !== "string") throw new Error(`Missing ${attr} translation: ${key}`);
    return `<${tag}${attributes}>${allowMarkup ? value : escapeHtml(value)}</${tag}>`;
  });
}

function render(locale) {
  const messages = locales[locale];
  let html = source
    .replace('<html lang="es">', `<html lang="${documentLocales[locale]}">`)
    .replace(/<title>[\s\S]*?<\/title>/, `<title>${escapeHtml(messages.meta.title)}</title>`)
    .replace(/<meta name="description" content="[^"]*">/, `<meta name="description" content="${escapeHtml(messages.meta.description || messages.hero.copy)}">`)
    .replace(/<meta property="og:title" content="[^"]*">/, `<meta property="og:title" content="${escapeHtml(messages.meta.title)}">`)
    .replace(/<meta property="og:description" content="[^"]*">/, `<meta property="og:description" content="${escapeHtml(messages.meta.description || messages.hero.copy)}">`)
    .replace(/<meta name="twitter:title" content="[^"]*">/, `<meta name="twitter:title" content="${escapeHtml(messages.meta.title)}">`)
    .replace(/<meta name="twitter:description" content="[^"]*">/, `<meta name="twitter:description" content="${escapeHtml(messages.meta.description || messages.hero.copy)}">`)
    .replace(/<meta property="og:image:alt" content="[^"]*">/, `<meta property="og:image:alt" content="Agustin Argüello — ${escapeHtml(messages.hero.eyebrow)}">`)
    .replace(/<meta property="og:url" content="[^"]*">/, `<meta property="og:url" content="https://agusquartz.github.io${localePaths[locale]}">`)
    .replace(/<link rel="canonical" href="[^"]*">/, `<link rel="canonical" href="https://agusquartz.github.io${localePaths[locale]}">`)
    .replace('"name": "Agustin Argüello | Software Developer"', `"name": "${messages.meta.title}"`)
    .replace('"jobTitle": "Software Developer"', `"jobTitle": "${messages.hero.eyebrow}"`)
    .replace('"name": "Agustin Argüello | Desarrollador de software"', `"name": "${messages.meta.title}"`)
    .replace('"jobTitle": "Desarrollador de software"', `"jobTitle": "${messages.hero.eyebrow}"`);

  const alternates = Object.entries(localePaths).map(([code, url]) => `<link rel="alternate" hreflang="${documentLocales[code]}" href="https://agusquartz.github.io${url}">`).join("\n    ");
  html = html.replace("    <script type=\"application/ld+json\">", `    ${alternates}\n    <script type="application/ld+json">`);
  html = replaceLocalizedContent(html, "data-i18n", messages);
  html = replaceLocalizedContent(html, "data-i18n-html", messages, true);
  html = html.replace(/(<[^>]+)data-i18n-aria-label="([^"]+)"([^>]*)(>)/g, (whole, before, key, after, close) => {
    const value = get(messages, key);
    if (typeof value !== "string") throw new Error(`Missing aria-label translation: ${key}`);
    const attributes = `${before}${after}`.replace(/\saria-label="[^"]*"/g, "");
    return `${attributes} aria-label="${escapeHtml(value)}"${close}`;
  });

  html = html.replace(/<button class="language-option" type="button" data-locale="([^"]+)" lang="[^"]+"(?: aria-current="true")?><span>[^<]*<\/span><span class="language-option-code">[^<]*<\/span><\/button>/g,
    (_, code) => `<a class="language-option" href="${localePaths[code]}" lang="${documentLocales[code]}"${code === locale ? ' aria-current="page"' : ""}><span>${languageNames[code]}</span><span class="language-option-code">${languageCodes[code]}</span></a>`);

  html = html.replace(/href="\.\/(academic-progress(?:\/curriculum-builder)?\/?)"/g, 'href="/$1"')
    .replace(/href="\.\/(simon-says-asm|HUFFMAN)\/"/g, 'href="/$1/"');
  html = html.replace(/src="\.\/assets\//g, 'src="/assets/');
  html = html.replace(/\sdata-i18n(?:-html|-aria-label|-alt)?="[^"]*"/g, "");

  const languageCode = languageCodes[locale];
  html = html.replace('<span class="language-code-current" id="languageCode">ES</span>', `<span class="language-code-current" id="languageCode">${languageCode}</span>`);
  const scriptStart = html.lastIndexOf("<script>");
  const scriptEnd = html.indexOf("</script>", scriptStart) + "</script>".length;
  const staticScript = `<script>
    const btnMenu = document.getElementById('btn-menu');
    const menuLinks = document.getElementById('menu-links');
    const languageSwitcher = document.getElementById('languageSwitcher');
    const languageButton = document.getElementById('languageButton');
    const copyEmailButton = document.getElementById('copyEmail');
    const copyPhoneButton = document.getElementById('copyPhone');
    const copyEmailStatus = document.getElementById('copyEmailStatus');
    const copyPhoneStatus = document.getElementById('copyPhoneStatus');
    btnMenu.addEventListener('click', () => {
      const isOpen = menuLinks.classList.toggle('active');
      btnMenu.setAttribute('aria-expanded', String(isOpen));
    });
    document.querySelectorAll('.nav-links a').forEach(link => link.addEventListener('click', () => {
      menuLinks.classList.remove('active'); btnMenu.setAttribute('aria-expanded', 'false');
    }));
    languageButton.addEventListener('click', () => {
      const isOpen = languageSwitcher.classList.toggle('open');
      languageButton.setAttribute('aria-expanded', String(isOpen));
    });
    function closeLanguageMenu() { languageSwitcher.classList.remove('open'); languageButton.setAttribute('aria-expanded', 'false'); }
    document.addEventListener('click', event => { if (!languageSwitcher.contains(event.target)) closeLanguageMenu(); });
    document.addEventListener('keydown', event => {
      if (event.key === 'Escape') { closeLanguageMenu(); menuLinks.classList.remove('active'); btnMenu.setAttribute('aria-expanded', 'false'); }
    });
    copyEmailButton.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText('agusquartz@gmail.com');
        copyEmailButton.textContent = '${escapeHtml(messages.contact.copied)}';
        copyEmailStatus.textContent = copyEmailButton.textContent;
      }
      catch { window.location.href = 'mailto:agusquartz@gmail.com'; }
    });
    copyPhoneButton.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText('+595 974 551 760');
        copyPhoneButton.textContent = '${escapeHtml(messages.contact.copied)}';
        copyPhoneStatus.textContent = copyPhoneButton.textContent;
      } catch {
        copyPhoneStatus.textContent = '${escapeHtml(messages.contact.copyError)}';
      }
    });
  </script>`;
  html = `${html.slice(0, scriptStart)}${staticScript}${html.slice(scriptEnd)}`;
  return html;
}

for (const [locale, url] of Object.entries(localePaths)) {
  const output = render(locale);
  if (url === "/") await writeFile(sourcePath, output, "utf8");
  else {
    const outputDirectory = path.join(root, url.slice(1));
    await mkdir(outputDirectory, { recursive: true });
    await writeFile(path.join(outputDirectory, "index.html"), output, "utf8");
  }
}
console.log(`Generated ${Object.keys(localePaths).length} static portfolio language pages.`);
