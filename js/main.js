/* Microclimate India — shared header/footer + small interactions.
   Header and footer live here so the menu only has to be edited in one place.
   Each page sets <body data-root="" data-page="home">; blog posts use data-root="../". */
(function () {
  var body = document.body;
  var root = body.getAttribute('data-root') || '';
  var page = body.getAttribute('data-page') || '';

  var SITE = {
    email: 'microclimateindia@gmail.com',
    phone: '0091 944-877-4778',
    phoneHref: '+919448774778',
    addressLines: ['Sayimane-Bidramane', 'PO: Sarakuli, Uttar Kannada,', 'Karnataka 581455', 'Western Ghats, India']
  };
  window.MCI_SITE = SITE;

  var NAV = [
    ['home', 'index.html', 'Home'],
    ['about', 'about.html', 'About Us'],
    ['projects', 'projects.html', 'Projects'],
    ['map', 'probe-map.html', 'Probe Map'],
    ['data', 'data.html', 'Data Portal'],
    ['blog', 'blog.html', 'Research & Blog'],
    ['involved', 'get-involved.html', 'Get Involved'],
    ['contact', 'contact.html', 'Contact']
  ];

  var logoSvg =
    '<svg class="brand-mark" viewBox="0 0 48 48" aria-hidden="true">' +
    '<circle cx="24" cy="24" r="23" fill="#645844"/>' +
    '<path d="M6 34c6-5 10-7 14-6s7 4 12 3 8-4 10-6v11a21 21 0 0 1-36-2z" fill="#2b5672" opacity=".9"/>' +
    '<path d="M24 9c7 3 11 9 10 16-1 5-5 8-10 8s-9-3-10-8c-1-7 3-13 10-16z" fill="#a9b709"/>' +
    '<path d="M24 12v24" stroke="#3d3528" stroke-width="1.6" stroke-linecap="round"/>' +
    '<path d="M24 20l-5-3M24 25l6-4M24 30l-5-3" stroke="#3d3528" stroke-width="1.3" stroke-linecap="round"/>' +
    '<circle cx="24" cy="38" r="3" fill="#d8d1c6"/>' +
    '</svg>';

  function brand(cls) {
    return '<a class="brand ' + (cls || '') + '" href="' + root + 'index.html" aria-label="Microclimate India home">' +
      logoSvg + '<span class="brand-text">MICROCLIMATE India<small>Western Ghats Research</small></span></a>';
  }

  var navLinks = NAV.map(function (n) {
    return '<a href="' + root + n[1] + '"' + (n[0] === page ? ' class="active" aria-current="page"' : '') + '>' + n[2] + '</a>';
  }).join('');

  var header =
    '<a class="skip-link" href="#main">Skip to content</a>' +
    '<header class="site-header"><div class="container header-inner">' + brand() +
    '<button class="nav-toggle" aria-label="Open menu" aria-expanded="false" aria-controls="site-nav">' +
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M3 6h18M3 12h18M3 18h18"/></svg></button>' +
    '<nav class="nav" id="site-nav" aria-label="Main">' + navLinks +
    '<a class="btn btn-donate' + (page === 'donate' ? ' active' : '') + '" href="' + root + 'donate.html">Donate</a>' +
    '</nav></div></header>';

  var footer =
    '<footer class="site-footer"><div class="container">' +
    '<div class="footer-grid">' +
    '<div class="footer-brand">' + brand() +
    '<p style="margin-top:18px">Microclimate India is a project led by Mr Balachandra Hegde, studying the influence of microclimate on diversity across the length of the Western Ghats.</p>' +
    '<a class="btn btn-donate" href="' + root + 'donate.html">Support our research</a></div>' +
    '<div><h4>Explore</h4><ul>' +
    '<li><a href="' + root + 'about.html">Research team</a></li>' +
    '<li><a href="' + root + 'projects.html">Projects</a></li>' +
    '<li><a href="' + root + 'probe-map.html">Probe map</a></li>' +
    '<li><a href="' + root + 'data.html">Data portal</a></li>' +
    '<li><a href="' + root + 'blog.html#publications">Publications</a></li><li><a href="' + root + 'blog.html#blog">Blog</a></li></ul></div>' +
    '<div><h4>Take part</h4><ul>' +
    '<li><a href="' + root + 'donate.html">Donate</a></li>' +
    '<li><a href="' + root + 'donate.html#adopt">Adopt a probe</a></li>' +
    '<li><a href="' + root + 'get-involved.html">Volunteer &amp; collaborate</a></li>' +
    '<li><a href="' + root + 'contact.html">Contact us</a></li></ul></div>' +
    '<div><h4>Contact</h4>' +
    '<p>Address: ' + SITE.addressLines.slice(0, 3).join('<br>') + '</p>' +
    '<p>Email: <a href="mailto:' + SITE.email + '">' + SITE.email + '</a><br>' +
    'Tel: <a href="tel:' + SITE.phoneHref + '">' + SITE.phone + '</a></p></div>' +
    '</div>' +
    '<div class="footer-bottom"><span>&copy; ' + new Date().getFullYear() + ' Microclimate India Research (MIR). All rights reserved.</span>' +
    '<span>In collaboration with Stockholm University &amp; The Green Concept, Pune</span></div>' +
    '</div></footer>';

  // Pages normally have the header/footer written in by tools/build-site.ps1 (better for search engines).
  // A page that still has the empty placeholders gets them filled in here instead.
  var h = document.getElementById('site-header');
  if (h) h.outerHTML = header;
  var f = document.getElementById('site-footer');
  if (f) f.outerHTML = footer;
  document.querySelectorAll('.js-year').forEach(function (el) { el.textContent = new Date().getFullYear(); });

  // Mobile nav
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.getElementById('site-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      var open = nav.classList.toggle('open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    nav.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') { nav.classList.remove('open'); toggle.setAttribute('aria-expanded', 'false'); }
    });
  }

  // Reveal on scroll
  var els = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) { if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); } });
    }, { threshold: 0.12 });
    els.forEach(function (el) { io.observe(el); });
  } else {
    els.forEach(function (el) { el.classList.add('in'); });
  }

  // Lightbox for .gallery images and [data-zoom]
  var zoomables = document.querySelectorAll('.gallery img, img[data-zoom]');
  if (zoomables.length) {
    var lb = document.createElement('div');
    lb.className = 'lightbox';
    lb.setAttribute('role', 'dialog');
    lb.setAttribute('aria-label', 'Image viewer');
    lb.innerHTML = '<img alt=""><div class="lightbox-cap"></div>';
    document.body.appendChild(lb);
    var lbImg = lb.querySelector('img'), lbCap = lb.querySelector('.lightbox-cap');
    zoomables.forEach(function (img) {
      img.addEventListener('click', function () {
        lbImg.src = img.currentSrc || img.src;
        lbImg.alt = img.alt;
        lbCap.textContent = img.getAttribute('data-caption') || img.alt || '';
        lb.classList.add('open');
      });
    });
    lb.addEventListener('click', function () { lb.classList.remove('open'); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') lb.classList.remove('open'); });
  }

  // Forms marked data-mailto: compose an email (works on GitHub Pages with no backend).
  // To use a form service instead (e.g. Formspree), set the form's action/method and remove data-mailto.
  document.querySelectorAll('form[data-mailto]').forEach(function (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var subjPrefix = form.getAttribute('data-subject') || 'Website enquiry';
      var lines = [];
      var name = '';
      Array.prototype.forEach.call(form.elements, function (el) {
        if (!el.name || el.type === 'submit') return;
        if (el.name === 'name') name = el.value;
        var label = form.querySelector('label[for="' + el.id + '"]');
        lines.push((label ? label.textContent : el.name) + ': ' + el.value);
      });
      var subject = subjPrefix + (name ? ' from ' + name : '');
      window.location.href = 'mailto:' + SITE.email + '?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(lines.join('\n'));
      var note = form.querySelector('.form-note');
      if (note) note.textContent = 'Your email app should open with the message ready to send. If it does not, write to us directly at ' + SITE.email + '.';
    });
  });
})();
