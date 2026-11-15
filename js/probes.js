/* =========================================================
   PROBE LOCATIONS: edit this file to update the probe map.
   Source: "TOMS logger Locations.kml" (Google Earth export).

   SITES   groups loggers by study site (name, region, project, partner)
   PROBES  one entry per TMS-4 logger:
     name      logger name as used in the field / KML
     site      key into SITES
     lat, lng  decimal degrees (WGS84)
     habitat   key into HABITATS
   Optional per-logger fields (shown in the popup when filled in):
     installed, status, data, notes
   ========================================================= */

var PROBES_ARE_PLACEHOLDERS = false;

var HABITATS = {
  swamp:     { label: 'Swamp',                 color: '#2b5672' },
  edge:      { label: 'Swamp / forest edge',   color: '#5f8fa8' },
  forest:    { label: 'Evergreen forest',      color: '#2f6b3a' },
  peak:      { label: 'Hilltop / peak',        color: '#a0702a' },
  open:      { label: 'Open & grassland',      color: '#9aa808' },
  other:     { label: 'Other sites',           color: '#645844' }
};

var SITES = {
  sayimane:   { name: 'Sayimane long-term monitoring site', region: 'Sayimane, Uttara Kannada, Karnataka',
                project: 'Microclimate in Western Ghats Forests',
                about: 'Our densest cluster: a long-term monitoring plot (LTM) with loggers at its four corners, plus forest-floor, valley, edge, open-grassland and Drosera (sundew) microsites.' },
  darbejaddi: { name: 'Darbejaddi swamp', region: 'Uttara Kannada, Karnataka', project: 'Myristica swamps',
                about: 'A swamp–evergreen forest–peak transect.' },
  chare:      { name: 'Chare swamp', region: 'Uttara Kannada, Karnataka', project: 'Myristica swamps',
                about: 'A swamp–evergreen forest–peak transect.' },
  choudikan:  { name: 'Choudikan swamp & Nilkund', region: 'Uttara Kannada, Karnataka', project: 'Myristica swamps',
                about: 'A swamp–edge–peak transect.' },
  kuvempu:    { name: 'Kuvempu University', region: 'Shankaraghatta, Shivamogga, Karnataka', project: 'Microclimate in Western Ghats Forests',
                partner: 'Kuvempu University' },
  elaeocarpus:{ name: 'Elaeocarpus swamp & Ajasra forest', region: 'Chikkamagaluru, Karnataka', project: 'Myristica swamps',
                about: 'A swamp–edge–peak transect with a nearby evergreen forest site.' },
  kuveshi:    { name: 'Kuveshi', region: 'Uttara Kannada, Karnataka', project: 'Microclimate in Western Ghats Forests' },
  chorla:     { name: 'Sada – Chorla Ghat', region: 'Chorla Ghat, Goa–Karnataka border', project: 'Microclimate in Western Ghats Forests',
                partner: 'Mhadei Research Centre' },
  bare:       { name: 'Bare', region: 'Uttara Kannada, Karnataka', project: 'Microclimate in Western Ghats Forests' },
  kadumane:   { name: 'Kadumane estate', region: 'Sakleshpur, Hassan, Karnataka', project: 'Microclimate in Western Ghats Forests' },
  shirkoli:   { name: 'Shirkoli', region: 'Pune, Maharashtra', project: 'Microclimate in Western Ghats Forests',
                partner: 'Agharkar Research Institute' },
  sangameshwar:{ name: 'Sangameshwar', region: 'Ratnagiri, Maharashtra', project: 'Microclimate in Western Ghats Forests',
                partner: 'Agharkar Research Institute' },
  vanaksavade:{ name: 'Vanaksavade', region: 'Satara, Maharashtra', project: 'Microclimate in Western Ghats Forests',
                partner: 'Agharkar Research Institute' }
};

var PROBES = [
  // Sayimane long-term monitoring site
  { name: 'Open',              site: 'sayimane', lat: 14.480072, lng: 74.760967, habitat: 'open' },
  { name: 'Edge',              site: 'sayimane', lat: 14.478865, lng: 74.759133, habitat: 'edge' },
  { name: 'Valley',            site: 'sayimane', lat: 14.478278, lng: 74.759123, habitat: 'forest' },
  { name: 'LTM NE',            site: 'sayimane', lat: 14.478953, lng: 74.761024, habitat: 'forest', notes: 'Corner of the long-term monitoring plot' },
  { name: 'LTM NW',            site: 'sayimane', lat: 14.478972, lng: 74.761918, habitat: 'forest', notes: 'Corner of the long-term monitoring plot' },
  { name: 'LTM SE',            site: 'sayimane', lat: 14.477807, lng: 74.761641, habitat: 'forest', notes: 'Corner of the long-term monitoring plot' },
  { name: 'LTM SW',            site: 'sayimane', lat: 14.477992, lng: 74.760958, habitat: 'forest', notes: 'Corner of the long-term monitoring plot' },
  { name: 'Open grassland',    site: 'sayimane', lat: 14.476775, lng: 74.762335, habitat: 'open' },
  { name: 'Forest floor',      site: 'sayimane', lat: 14.477926, lng: 74.760357, habitat: 'forest' },
  { name: 'Drosera 1',         site: 'sayimane', lat: 14.480748, lng: 74.759375, habitat: 'open', notes: 'Sundew (Drosera) microhabitat' },
  { name: 'Drosera 2',         site: 'sayimane', lat: 14.480652, lng: 74.759339, habitat: 'open', notes: 'Sundew (Drosera) microhabitat' },
  { name: 'Drosera 3',         site: 'sayimane', lat: 14.480700, lng: 74.759271, habitat: 'open', notes: 'Sundew (Drosera) microhabitat' },

  // Darbejaddi
  { name: 'Darbejaddi Swamp',             site: 'darbejaddi', lat: 14.415597, lng: 74.770778, habitat: 'swamp' },
  { name: 'Swamp peak',                   site: 'darbejaddi', lat: 14.418742, lng: 74.768136, habitat: 'peak' },
  { name: 'Evergreen forest Darbejaddi',  site: 'darbejaddi', lat: 14.416035, lng: 74.770146, habitat: 'forest' },

  // Chare
  { name: 'Chare Swamp',       site: 'chare', lat: 14.413055, lng: 74.740155, habitat: 'swamp' },
  { name: 'Chare evergreen',   site: 'chare', lat: 14.413354, lng: 74.740502, habitat: 'forest' },
  { name: 'Chare peak',        site: 'chare', lat: 14.415016, lng: 74.740487, habitat: 'peak' },

  // Choudikan / Nilkund
  { name: 'Swamp Choudikan',   site: 'choudikan', lat: 14.448232, lng: 74.695439, habitat: 'swamp' },
  { name: 'Swamp Edge',        site: 'choudikan', lat: 14.448261, lng: 74.695089, habitat: 'edge' },
  { name: 'Peak Nilkund',      site: 'choudikan', lat: 14.448170, lng: 74.694809, habitat: 'peak' },

  // Kuvempu University
  { name: 'Kuvempu University', site: 'kuvempu', lat: 13.733773, lng: 75.625385, habitat: 'other' },

  // Elaeocarpus swamp & Ajasra
  { name: 'Elaeocarpus swamp',        site: 'elaeocarpus', lat: 13.366553, lng: 75.288218, habitat: 'swamp' },
  { name: 'Swamp edge',               site: 'elaeocarpus', lat: 13.366208, lng: 75.287294, habitat: 'edge' },
  { name: 'Elaeocarpus peak',         site: 'elaeocarpus', lat: 13.364307, lng: 75.290857, habitat: 'peak' },
  { name: 'Ajasra evergreen forest',  site: 'elaeocarpus', lat: 13.371224, lng: 75.223806, habitat: 'forest' },

  // Single sites
  { name: 'Kuveshi',           site: 'kuveshi',  lat: 15.359310, lng: 74.329201, habitat: 'other' },
  { name: 'Sada – Chorla Ghat',site: 'chorla',   lat: 15.652980, lng: 74.119519, habitat: 'other' },
  { name: 'Evergreen forest',  site: 'chorla',   lat: 15.651409, lng: 74.118953, habitat: 'forest' },
  { name: 'Bare',              site: 'bare',     lat: 14.809201, lng: 74.486264, habitat: 'other' },
  { name: 'Kadumane estate',   site: 'kadumane', lat: 12.940779, lng: 75.667174, habitat: 'other' },
  { name: 'Shirkoli',          site: 'shirkoli', lat: 18.328491, lng: 73.574169, habitat: 'other' },
  { name: 'Sangameshwar',      site: 'sangameshwar', lat: 17.186186, lng: 73.544442, habitat: 'other' },
  { name: 'Vanaksavade',       site: 'vanaksavade',  lat: 17.488828, lng: 73.826001, habitat: 'other' }
];

/* Plot outlines drawn on the map (from the KML "quadrant" polygon). [lat, lng] pairs. */
var PLOTS = [
  { name: 'Sayimane long-term monitoring plot', coords: [
    [14.477995, 74.760974], [14.477817, 74.761636], [14.479022, 74.761922], [14.479016, 74.761039]
  ] }
];
