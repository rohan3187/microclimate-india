# Microclimate India website

Static website for the Microclimate India Research (MIR) project. Plain HTML, CSS and JavaScript with no build step, so it can be hosted on GitHub Pages and served at **microclimateindia.com**.

## Structure

| Path | What it is |
|---|---|
| `index.html` | Home |
| `about.html` | Research team |
| `projects.html` | Project details (#western-ghats-forests, #myristica-swamps, #bioluminescent-forest-floor) |
| `probe-map.html` | Interactive probe map (Leaflet) |
| `data.html` | Data portal (placeholder) and data request form |
| `blog.html`, `blog/*.html` | Blog index and posts |
| `get-involved.html` | Volunteer, collaborate, host a probe |
| `donate.html` | Fundraising page (tiers, adopt a probe, payment details) |
| `contact.html` | Contact details and form |
| `css/style.css` | All styles. Colours are defined at the top. |
| `js/main.js` | Shared header, menu, footer and contact details. **Edit the menu, email, phone or address here.** |
| `js/probes.js` | **Probe locations for the map.** Edit this to add or update probes. |
| `assets/img/` | Web-sized images (team photos in `team/`, blog images in `blog/`) |
| `CNAME` | Custom domain for GitHub Pages |

## Preview locally

Double-click `index.html`, or run a small local server from this folder:

```
python -m http.server 8000
```

Then open http://localhost:8000.

## Common edits

- **Add or update a probe:** edit `js/probes.js`. Copy an entry, change the fields, then set `PROBES_ARE_PLACEHOLDERS = false` once the real coordinates are in.
- **Add a blog post:** copy one of the files in `blog/`, change the title, date and body, then add a card for it in `blog.html` (and on `index.html` if it should appear on the home page).
- **Add a team member:** add a 480×480 photo to `assets/img/team/`, then copy one `<article class="member">` block in `about.html`.
- **Donation details:** replace the "Details coming soon" lines in `donate.html` (search for `TODO`).
- **Forms:** forms open the visitor's email app (`data-mailto`). To receive submissions without email, sign up for a form service such as Formspree, then set the form's `action` attribute to the service's URL, add `method="POST"`, and remove `data-mailto`.

## Publish on GitHub Pages

1. Create a GitHub repository (e.g. `microclimateindia`) and push the contents of this `site` folder to the root of the `main` branch.
2. In the repository, go to **Settings → Pages**, set *Source* to **Deploy from a branch** and pick `main` / `(root)`.
3. The `CNAME` file sets the custom domain to `microclimateindia.com`.
4. At your domain registrar, add these DNS records:
   - `A` records for `@` pointing to `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - a `CNAME` record for `www` pointing to `<your-github-username>.github.io`
5. Back in **Settings → Pages**, wait for the DNS check to pass, then tick **Enforce HTTPS**.
