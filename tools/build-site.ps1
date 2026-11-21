<#
  Microclimate India - site builder (search-engine & AI visibility)

  What it does, for every page:
    * writes the menu (header) and footer straight into the HTML, so crawlers that
      don't run JavaScript still see navigation, address, email and phone
    * sets the page title + description, canonical link, social-preview tags
      (WhatsApp / LinkedIn / X) and structured data (schema.org JSON-LD)
    * pre-fills the probe-map site list from js/probes.js
    * regenerates sitemap.xml

  When to run it: after changing the menu/footer/contact details below, after
  adding a page or blog post (add it to $PAGES), or after editing js/probes.js.

  How to run it (Windows): right-click this file > "Run with PowerShell",
  or in PowerShell:  powershell -ExecutionPolicy Bypass -File tools\build-site.ps1
  Then commit & push in GitHub Desktop as usual.

  Keep this file plain ASCII: write special characters as HTML entities
  (&amp; &ndash; &middot; &rsquo;) so Windows PowerShell reads it correctly.
#>

$ErrorActionPreference = 'Stop'
$ROOT = Split-Path -Parent $PSScriptRoot
$BASE = 'https://microclimateindia.com/'
$UTF8 = New-Object System.Text.UTF8Encoding $false

# ---------------- SITE DETAILS (edit here) ----------------
$SITE = @{
  Name      = 'Microclimate India Research'
  Short     = 'Microclimate India'
  Email     = 'microclimateindia@gmail.com'
  Phone     = '0091 944-877-4778'
  PhoneHref = '+919448774778'
  Address   = @('Sayimane-Bidramane', 'PO: Sarakuli, Uttar Kannada,', 'Karnataka 581455')
  Postcode  = '581455'
}

# Menu: key (matches <body data-page>), file, label
$NAV = @(
  @('home','index.html','Home'),
  @('about','about.html','About Us'),
  @('projects','projects.html','Projects'),
  @('map','probe-map.html','Probe Map'),
  @('data','data.html','Data Portal'),
  @('blog','blog.html','Research &amp; Blog'),
  @('involved','get-involved.html','Get Involved'),
  @('contact','contact.html','Contact')
)

# Pages: file, title, description (leave Title/Desc empty to keep what the page has), type
$PAGES = @(
  @{ File='index.html'; Type='home'
     Title='Microclimate India | Western Ghats microclimate research &amp; data'
     Desc='Microclimate India Research (MIR) runs India&rsquo;s first microclimate logger network: 34 TMS-4 loggers across the Western Ghats measuring forest temperature and soil moisture to help conserve biodiversity.' },
  @{ File='about.html'; Type='about'
     Title='Research team | Microclimate India'
     Desc='Meet the ecologists, botanists and data scientists behind Microclimate India, studying how microclimate shapes biodiversity across the Western Ghats.' },
  @{ File='projects.html'; Type='page'
     Title='Research projects: forests, Myristica swamps &amp; bioluminescence | Microclimate India'
     Desc='Our projects on microclimate in Western Ghats forests, Myristica swamps and the bioluminescent forest floor: how fine-scale climate shapes plant and animal diversity.' },
  @{ File='probe-map.html'; Type='page'
     Title='Probe map: microclimate loggers in the Western Ghats | Microclimate India'
     Desc='Interactive map of 34 TMS-4 microclimate loggers at 13 sites from Sakleshpur to Pune, in Myristica swamps, evergreen forest, forest edges, hilltops and grasslands.' },
  @{ File='data.html'; Type='dataset'
     Title='Data portal: Western Ghats microclimate data | Microclimate India'
     Desc='Request 15-minute soil, surface and air temperature and soil moisture records from India&rsquo;s first microclimate logger network in the Western Ghats.' },
  @{ File='blog.html'; Type='blog'
     Title='Publications &amp; blog | Microclimate India'
     Desc='Peer-reviewed research on Myristica swamp microclimate, plus field notes and explainers on microclimate science from the Western Ghats of India.' },
  @{ File='get-involved.html'; Type='page'
     Title='Get involved: volunteer, host a logger, collaborate | Microclimate India'
     Desc='Volunteer, host a logger, collaborate or study with Microclimate India: ways to support microclimate and biodiversity research in the Western Ghats.' },
  @{ File='donate.html'; Type='page'
     Title='Donate to Western Ghats microclimate research | Microclimate India'
     Desc='Support India&rsquo;s first microclimate network. Adopt a logger, fund field work and help build the data needed to conserve Western Ghats biodiversity.' },
  @{ File='contact.html'; Type='page'
     Title='Contact | Microclimate India'
     Desc='Contact Microclimate India Research, Sayimane-Bidramane, Uttara Kannada, Karnataka. Write to microclimateindia@gmail.com about collaborations, data or donations.' },
  @{ File='blog/reflection-on-the-microclimate-research.html'; Type='post'; Date='2025-02-21'; Author='Swanand Khanapurkar' },
  @{ File='blog/what-exactly-is-microclimate.html'; Type='post'; Date='2025-02-20' },
  @{ File='blog/secrets-of-myristica-swamps.html'; Type='post'; Date='2024-10-16' },
  @{ File='404.html'; Type='404' }
)

# Publications (newest first) - used for structured data on blog.html
$PUBS = @(
  [ordered]@{ '@type'='ScholarlyArticle'
    headline='Microclimatic niche separation among swamp, forest, and edge species in Myristica swamps of the Western Ghats, India'
    author=@('Balachandra Hegde','Narasimha Hegde','H. V. Raghavendra','Rohan Shetti','Yogendra Kambalagere' | ForEach-Object { [ordered]@{ '@type'='Person'; name=$_ } })
    datePublished='2026-04-12'
    isPartOf=[ordered]@{ '@type'='Periodical'; name='Wetlands Ecology and Management' }
    volumeNumber='34'; issueNumber='2'
    identifier='https://doi.org/10.1007/s11273-026-10127-x'
    url='https://doi.org/10.1007/s11273-026-10127-x'
    about='Myristica swamps; microclimate; Western Ghats' }
)
# -----------------------------------------------------------

function Read-Text($p)  { [IO.File]::ReadAllText($p, $UTF8) }
function Write-Text($p, $t) { [IO.File]::WriteAllText($p, $t, $UTF8) }
function Dec($s) { [System.Net.WebUtility]::HtmlDecode($s) }
function Esc($s) { [System.Net.WebUtility]::HtmlEncode($s) }
function Replace-Block($text, $name, $content, $fallbackPattern) {
  $start = "<!-- $name -->"; $end = "<!-- /$name -->"
  $block = "$start`n$content`n$end"
  $rx = [regex]::Escape($start) + '[\s\S]*?' + [regex]::Escape($end)
  if ($text -match $rx) { return [regex]::Replace($text, $rx, { param($m) $block }) }
  if ($fallbackPattern -and ($text -match $fallbackPattern)) {
    $r = New-Object System.Text.RegularExpressions.Regex ('(?s)' + $fallbackPattern)
    $ins = "$block`n"
    return $r.Replace($text, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $ins }, 1)
  }
  throw "Could not place block $name"
}
function Json($obj) { ($obj | ConvertTo-Json -Depth 12 -Compress) }

$logo = '<svg class="brand-mark" viewBox="0 0 48 48" aria-hidden="true"><circle cx="24" cy="24" r="23" fill="#645844"/><path d="M6 34c6-5 10-7 14-6s7 4 12 3 8-4 10-6v11a21 21 0 0 1-36-2z" fill="#2b5672" opacity=".9"/><path d="M24 9c7 3 11 9 10 16-1 5-5 8-10 8s-9-3-10-8c-1-7 3-13 10-16z" fill="#a9b709"/><path d="M24 12v24" stroke="#3d3528" stroke-width="1.6" stroke-linecap="round"/><path d="M24 20l-5-3M24 25l6-4M24 30l-5-3" stroke="#3d3528" stroke-width="1.3" stroke-linecap="round"/><circle cx="24" cy="38" r="3" fill="#d8d1c6"/></svg>'

function Header($root, $page) {
  $brand = "<a class=`"brand `" href=`"${root}index.html`" aria-label=`"Microclimate India home`">$logo<span class=`"brand-text`">MICROCLIMATE India<small>Western Ghats Research</small></span></a>"
  $links = ($NAV | ForEach-Object {
    $act = if ($_[0] -eq $page) { ' class="active" aria-current="page"' } else { '' }
    "<a href=`"$root$($_[1])`"$act>$($_[2])</a>" }) -join ''
  $don = if ($page -eq 'donate') { ' active' } else { '' }
  return "<a class=`"skip-link`" href=`"#main`">Skip to content</a>`n<header class=`"site-header`"><div class=`"container header-inner`">$brand<button class=`"nav-toggle`" aria-label=`"Open menu`" aria-expanded=`"false`" aria-controls=`"site-nav`"><svg viewBox=`"0 0 24 24`" fill=`"none`" stroke=`"currentColor`" stroke-width=`"2`" stroke-linecap=`"round`"><path d=`"M3 6h18M3 12h18M3 18h18`"/></svg></button><nav class=`"nav`" id=`"site-nav`" aria-label=`"Main`">$links<a class=`"btn btn-donate$don`" href=`"${root}donate.html`">Donate</a></nav></div></header>"
}

function Footer($root) {
  $brand = "<a class=`"brand `" href=`"${root}index.html`" aria-label=`"Microclimate India home`">$logo<span class=`"brand-text`">MICROCLIMATE India<small>Western Ghats Research</small></span></a>"
  $addr = $SITE.Address -join '<br>'
  $yr = (Get-Date).Year
  return @"
<footer class="site-footer"><div class="container"><div class="footer-grid">
<div class="footer-brand">$brand<p style="margin-top:18px">Microclimate India is a project led by Mr Balachandra Hegde, studying the influence of microclimate on diversity across the length of the Western Ghats.</p><a class="btn btn-donate" href="${root}donate.html">Support our research</a></div>
<div><h4>Explore</h4><ul><li><a href="${root}about.html">Research team</a></li><li><a href="${root}projects.html">Projects</a></li><li><a href="${root}probe-map.html">Probe map</a></li><li><a href="${root}data.html">Data portal</a></li><li><a href="${root}blog.html#publications">Publications</a></li><li><a href="${root}blog.html#blog">Blog</a></li></ul></div>
<div><h4>Take part</h4><ul><li><a href="${root}donate.html">Donate</a></li><li><a href="${root}donate.html#adopt">Adopt a probe</a></li><li><a href="${root}get-involved.html">Volunteer &amp; collaborate</a></li><li><a href="${root}contact.html">Contact us</a></li></ul></div>
<div><h4>Contact</h4><p>Address: $addr</p><p>Email: <a href="mailto:$($SITE.Email)">$($SITE.Email)</a><br>Tel: <a href="tel:$($SITE.PhoneHref)">$($SITE.Phone)</a></p></div>
</div>
<div class="footer-bottom"><span>&copy; <span class="js-year">$yr</span> Microclimate India Research (MIR). All rights reserved.</span><span>In collaboration with Stockholm University &amp; The Green Concept, Pune</span></div>
</div></footer>
"@
}

$ORG = [ordered]@{
  '@type' = 'ResearchOrganization'; '@id' = "${BASE}#org"
  name = $SITE.Name; alternateName = @('MIR','Microclimate India')
  url = $BASE; logo = "${BASE}assets/img/og-default.jpg"
  email = $SITE.Email; telephone = '+91-9448774778'
  description = "Microclimate India Research (MIR) runs India's first microclimate logger network, studying how fine-scale forest climate shapes biodiversity across the Western Ghats."
  address = [ordered]@{ '@type'='PostalAddress'; streetAddress='Sayimane-Bidramane, PO: Sarakuli'; addressRegion='Uttara Kannada, Karnataka'; postalCode=$SITE.Postcode; addressCountry='IN' }
  areaServed = 'Western Ghats, India'
  founder = [ordered]@{ '@type'='Person'; name='Balachandra Hegde' }
  knowsAbout = @('Microclimate','Western Ghats','Myristica swamps','Forest ecology','Biodiversity conservation','TMS-4 data loggers','Soil moisture','Climate change ecology')
}

# Probe sites (for the static list on the map page and the dataset's spatial coverage)
$probesJs = Read-Text (Join-Path $ROOT 'js\probes.js')
$siteRx = [regex]"(?m)^\s*(\w+)\s*:\s*\{\s*name:\s*'([^']+)',\s*region:\s*'([^']+)'"
$siteList = foreach ($m in $siteRx.Matches($probesJs)) { [pscustomobject]@{ Key=$m.Groups[1].Value; Name=$m.Groups[2].Value; Region=$m.Groups[3].Value } }
$probeRx = [regex]"site:\s*'(\w+)',\s*lat:\s*([\d.]+),\s*lng:\s*([\d.]+)"
$probes = foreach ($m in $probeRx.Matches($probesJs)) { [pscustomobject]@{ Site=$m.Groups[1].Value; Lat=[double]$m.Groups[2].Value; Lng=[double]$m.Groups[3].Value } }
$nProbes = @($probes).Count; $nSites = @($siteList).Count
$box = '{0:0.00} {1:0.00} {2:0.00} {3:0.00}' -f ($probes.Lat | Measure-Object -Minimum).Minimum, ($probes.Lng | Measure-Object -Minimum).Minimum, ($probes.Lat | Measure-Object -Maximum).Maximum, ($probes.Lng | Measure-Object -Maximum).Maximum

$today = (Get-Date).ToString('yyyy-MM-dd')
$sitemap = New-Object System.Collections.Generic.List[string]

foreach ($pg in $PAGES) {
  $path = Join-Path $ROOT $pg.File
  $t = Read-Text $path
  $rel = [regex]::Match($t, '<body[^>]*data-root="([^"]*)"').Groups[1].Value
  $page = [regex]::Match($t, '<body[^>]*data-page="([^"]*)"').Groups[1].Value

  # Header & footer
  $t = Replace-Block $t 'LAYOUT:HEADER' (Header $rel $page) '<div id="site-header"></div>'
  $t = Replace-Block $t 'LAYOUT:FOOTER' (Footer $rel) '<div id="site-footer"></div>'

  # Title & description
  if ($pg.Title) { $t = [regex]::Replace($t, '<title>[\s\S]*?</title>', "<title>$($pg.Title)</title>") }
  if ($pg.Desc)  {
    if ($t -match '<meta name="description"') { $t = [regex]::Replace($t, '<meta name="description" content="[^"]*">', "<meta name=`"description`" content=`"$($pg.Desc)`">") }
    else { $t = $t.Replace('</title>', "</title>`n  <meta name=`"description`" content=`"$($pg.Desc)`">") }
  }
  $title = Dec ([regex]::Match($t, '<title>([\s\S]*?)</title>').Groups[1].Value)
  $desc  = Dec ([regex]::Match($t, '<meta name="description" content="([^"]*)"').Groups[1].Value)
  $h1    = Dec (([regex]::Match($t, '<h1[^>]*>([\s\S]*?)</h1>').Groups[1].Value) -replace '<[^>]+>','').Trim()

  # Old one-off OG tags on the home page are replaced by the generated block
  $t = [regex]::Replace($t, '\s*<meta property="og:[^"]+" content="[^"]*">', '')

  $url = if ($pg.File -eq 'index.html') { $BASE } else { $BASE + $pg.File }
  $imgRel = [regex]::Match($t, "url\('(?:\.\./)?(assets/img/[^']+)'\)").Groups[1].Value
  if (-not $imgRel) { $imgRel = [regex]::Match($t, 'src="(?:\.\./)?(assets/img/[^"]+\.jpg)"').Groups[1].Value }
  if (-not $imgRel) { $imgRel = 'assets/img/og-default.jpg' }
  $img = $BASE + $imgRel

  $graph = New-Object System.Collections.ArrayList
  [void]$graph.Add($ORG)
  $webpage = [ordered]@{ '@type'='WebPage'; '@id'="$url#page"; url=$url; name=$title; description=$desc; isPartOf=[ordered]@{ '@id'="${BASE}#website" }; publisher=[ordered]@{ '@id'="${BASE}#org" }; primaryImageOfPage=$img; inLanguage='en' }

  switch ($pg.Type) {
    'home' {
      [void]$graph.Add([ordered]@{ '@type'='WebSite'; '@id'="${BASE}#website"; url=$BASE; name=$SITE.Name; alternateName='Microclimate India'; publisher=[ordered]@{ '@id'="${BASE}#org" }; inLanguage='en' })
      [void]$graph.Add($webpage)
    }
    'about' {
      $people = foreach ($m in [regex]::Matches($t, '(?s)<article class="member[^"]*">.*?<h3>(.*?)</h3>(?:\s*<div class="role">(.*?)</div>)?')) {
        $p = [ordered]@{ '@type'='Person'; name=(Dec ($m.Groups[1].Value -replace '<[^>]+>','')).Trim() }
        if ($m.Groups[2].Success -and $m.Groups[2].Value) { $p.description = (Dec ($m.Groups[2].Value -replace '<[^>]+>','')).Trim() }
        $p.memberOf = [ordered]@{ '@id'="${BASE}#org" }
        $p
      }
      $webpage['@type'] = 'AboutPage'
      [void]$graph.Add($webpage)
      [void]$graph.Add([ordered]@{ '@type'='Person'; name='Balachandra Hegde'; jobTitle='Principal Investigator'; affiliation=[ordered]@{ '@type'='CollegeOrUniversity'; name='Kuvempu University' }; memberOf=[ordered]@{ '@id'="${BASE}#org" } })
      foreach ($p in $people) { [void]$graph.Add($p) }
    }
    'blog' {
      $webpage['@type'] = 'CollectionPage'
      [void]$graph.Add($webpage)
      foreach ($p in $PUBS) { [void]$graph.Add($p) }
    }
    'dataset' {
      [void]$graph.Add($webpage)
      [void]$graph.Add([ordered]@{
        '@type'='Dataset'; '@id'="$url#dataset"
        name='Western Ghats microclimate logger data (Microclimate India Research)'
        alternateName='MIR TMS-4 microclimate dataset'
        description="Continuous microclimate records from India's first microclimate logger network: $nProbes TOMST TMS-4 data loggers at $nSites study sites across the central and northern Western Ghats of India, in Myristica swamps, evergreen forest, forest edges, hilltops and open grasslands. Each logger records soil temperature (-6 cm), surface temperature (+2 cm), air temperature (+15 cm) and soil moisture every 15 minutes. Data are available to researchers on request from the MIR team."
        url=$url
        keywords=@('microclimate','Western Ghats','India','soil temperature','air temperature','soil moisture','TMS-4','Myristica swamp','forest microclimate','biodiversity hotspot')
        creator=[ordered]@{ '@id'="${BASE}#org" }
        publisher=[ordered]@{ '@id'="${BASE}#org" }
        measurementTechnique='TOMST TMS-4 data logger'
        variableMeasured=@('Soil temperature at -6 cm','Surface temperature at +2 cm','Air temperature at +15 cm','Soil moisture')
        spatialCoverage=[ordered]@{ '@type'='Place'; name='Western Ghats, Karnataka, Goa and Maharashtra, India'; geo=[ordered]@{ '@type'='GeoShape'; box=$box } }
        conditionsOfAccess='Available on request from Microclimate India Research. See the data portal page for how to request data.'
        isAccessibleForFree=$false
      })
    }
    'post' {
      $webpage['@type'] = 'WebPage'
      [void]$graph.Add($webpage)
      $author = if ($pg.Author) { [ordered]@{ '@type'='Person'; name=$pg.Author } } else { [ordered]@{ '@id'="${BASE}#org" } }
      [void]$graph.Add([ordered]@{ '@type'='BlogPosting'; headline=$h1; description=$desc; image=$img; datePublished=$pg.Date; author=$author; publisher=[ordered]@{ '@id'="${BASE}#org" }; mainEntityOfPage=$url; inLanguage='en' })
    }
    default { [void]$graph.Add($webpage) }
  }

  $ld = Json ([ordered]@{ '@context'='https://schema.org'; '@graph'=$graph })
  $ogType = if ($pg.Type -eq 'post') { 'article' } else { 'website' }
  if ($pg.Type -eq '404') {
    $seo = '  <meta name="robots" content="noindex">'
  } else {
    $seo = @"
  <link rel="canonical" href="$url">
  <meta property="og:site_name" content="Microclimate India">
  <meta property="og:type" content="$ogType">
  <meta property="og:title" content="$(Esc $title)">
  <meta property="og:description" content="$(Esc $desc)">
  <meta property="og:url" content="$url">
  <meta property="og:image" content="$img">
  <meta property="og:locale" content="en_IN">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$(Esc $title)">
  <meta name="twitter:description" content="$(Esc $desc)">
  <meta name="twitter:image" content="$img">
  <script type="application/ld+json">$ld</script>
"@
    $prio = if ($pg.File -eq 'index.html') { '1.0' } elseif ($pg.Type -eq 'post') { '0.6' } else { '0.8' }
    $sitemap.Add("  <url><loc>$url</loc><lastmod>$today</lastmod><priority>$prio</priority></url>")
  }
  $t = Replace-Block $t 'SEO' $seo '(?=</head>)'

  # Static site list on the probe map (JavaScript replaces it with the interactive list)
  if ($pg.File -eq 'probe-map.html') {
    $items = foreach ($s in $siteList) {
      $n = @($probes | Where-Object { $_.Site -eq $s.Key }).Count
      "<li><button type=`"button`" style=`"display:block;background:var(--sand);padding:12px 18px`"><strong>$(Esc $s.Name)</strong><span>$(Esc $s.Region) &middot; $n logger$(if ($n -ne 1) {'s'})</span></button></li>"
    }
    $t = [regex]::Replace($t, '(<ul class="probe-list" id="probe-list">)[\s\S]*?(</ul>)', { param($m) $m.Groups[1].Value + "`n" + ($items -join "`n") + "`n" + $m.Groups[2].Value })
  }

  Write-Text $path $t
  Write-Host "updated $($pg.File)"
}

$xml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n" + ($sitemap -join "`n") + "`n</urlset>`n"
Write-Text (Join-Path $ROOT 'sitemap.xml') $xml
Write-Host "sitemap.xml: $($sitemap.Count) pages"
