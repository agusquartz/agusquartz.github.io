(() => {
  const localeCodes = { es: 'ES', en: 'EN', pt: 'PT', 'zh-Hant': '繁中', ru: 'RU', de: 'DE' };
  const documentLocales = { es: 'es', en: 'en', pt: 'pt-BR', 'zh-Hant': 'zh-Hant', ru: 'ru', de: 'de' };
  const options = [
    ['es', 'es', 'Español', 'ES'], ['en', 'en', 'English', 'EN'], ['pt', 'pt-BR', 'Português', 'PT'],
    ['zh-Hant', 'zh-Hant', '繁體中文', '繁中'], ['ru', 'ru', 'Русский', 'RU'], ['de', 'de', 'Deutsch', 'DE']
  ];

  function get(messages, path) {
    return path.split('.').reduce((value, part) => value && value[part], messages);
  }

  function apply(messages, prefix) {
    document.querySelectorAll('[data-i18n]').forEach(element => {
      const path = element.dataset.i18n;
      const value = get(messages, path) || (path.startsWith('academic.ui.') && get(messages, `academicUi.${path.slice('academic.ui.'.length)}`));
      if (typeof value === 'string') element.textContent = value;
    });
    document.querySelectorAll('[data-i18n-html]').forEach(element => {
      const path = element.dataset.i18nHtml;
      const value = get(messages, path) || (path.startsWith('academic.ui.') && get(messages, `academicUi.${path.slice('academic.ui.'.length)}`));
      if (typeof value === 'string') element.innerHTML = value;
    });
    document.querySelectorAll('[data-i18n-aria-label]').forEach(element => {
      const path = element.dataset.i18nAriaLabel;
      const value = get(messages, path) || (path.startsWith('academic.ui.') && get(messages, `academicUi.${path.slice('academic.ui.'.length)}`));
      if (typeof value === 'string') element.setAttribute('aria-label', value);
    });
    return get(messages, prefix);
  }

  function mount({ slot, prefix, basePath = '../locales', onLocale }) {
    const mountPoint = document.querySelector(slot);
    if (!mountPoint) return;

    mountPoint.innerHTML = `<div class="language-switcher"><button class="language-button" type="button" aria-expanded="false" aria-haspopup="true" aria-controls="languageMenu" aria-label="Cambiar idioma"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 8 6 6"/><path d="m4 14 6-6 2-3"/><path d="M2 5h12"/><path d="M7 2h1"/><path d="m22 22-5-10-5 10"/><path d="M14 18h6"/></svg><span class="language-code-current">ES</span></button><div class="language-menu" id="languageMenu">${options.map(([locale, lang, label, code]) => `<button class="language-option" type="button" data-locale="${locale}" lang="${lang}"><span>${label}</span><span class="language-option-code">${code}</span></button>`).join('')}</div></div>`;
    const switcher = mountPoint.querySelector('.language-switcher');
    const button = mountPoint.querySelector('.language-button');
    const code = mountPoint.querySelector('.language-code-current');
    const close = () => { switcher.classList.remove('open'); button.setAttribute('aria-expanded', 'false'); };

    async function setLocale(locale) {
      try {
        const response = await fetch(`${basePath}/${locale}.json?rev=2`);
        if (!response.ok) throw new Error(`Could not load locale: ${locale}`);
        const messages = await response.json();
        const translation = apply(messages, prefix);
        const aria = get(messages, 'language.aria');
        if (aria) button.setAttribute('aria-label', aria);
        document.documentElement.lang = documentLocales[locale] || locale;
        code.textContent = localeCodes[locale] || locale.toUpperCase();
        switcher.querySelectorAll('.language-option').forEach(option => option.setAttribute('aria-current', String(option.dataset.locale === locale)));
        localStorage.setItem('portfolio-locale', locale);
        if (typeof onLocale === 'function') onLocale(translation, messages, locale);
      } catch (error) {
        console.error('Language selection failed.', error);
      }
    }

    button.addEventListener('click', () => {
      const isOpen = switcher.classList.toggle('open');
      button.setAttribute('aria-expanded', String(isOpen));
    });
    switcher.querySelectorAll('.language-option').forEach(option => option.addEventListener('click', () => { setLocale(option.dataset.locale); close(); }));
    document.addEventListener('click', event => { if (!switcher.contains(event.target)) close(); });
    document.addEventListener('keydown', event => { if (event.key === 'Escape') close(); });
    setLocale(localStorage.getItem('portfolio-locale') || 'es');
  }

  window.PortfolioI18n = { mount, get };
})();
