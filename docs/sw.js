// Cache para funcionar offline depois do primeiro acesso.
const CACHE = 'foto-txt-v1';
const ASSETS = ['./', 'index.html', 'app.js', 'manifest.webmanifest', 'icon-192.png', 'icon-512.png',
  'lib/tesseract.min.js', 'lib/worker.min.js',
  'lib/core/tesseract-core-lstm.js', 'lib/core/tesseract-core-lstm.wasm', 'lib/core/tesseract-core-lstm.wasm.js',
  'lib/core/tesseract-core-simd-lstm.js', 'lib/core/tesseract-core-simd-lstm.wasm', 'lib/core/tesseract-core-simd-lstm.wasm.js',
  'lib/core/tesseract-core-relaxedsimd-lstm.js', 'lib/core/tesseract-core-relaxedsimd-lstm.wasm', 'lib/core/tesseract-core-relaxedsimd-lstm.wasm.js',
  'lib/lang/por.traineddata.gz', 'lib/lang/eng.traineddata.gz'];
self.addEventListener('install', (e) => { e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting())); });
self.addEventListener('activate', (e) => { e.waitUntil(caches.keys().then((k) => Promise.all(k.filter((x) => x !== CACHE).map((x) => caches.delete(x)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', (e) => { if (e.request.method === 'GET') e.respondWith(caches.match(e.request).then((r) => r || fetch(e.request))); });
