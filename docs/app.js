const $ = (id) => document.getElementById(id);
const MAX_SIDE = 2200; // reduz fotos enormes do celular para o OCR ficar rápido

let worker = null, workerLang = null;

async function getWorker(lang) {
  if (worker && workerLang === lang) return worker;
  if (worker) { await worker.terminate(); worker = null; }
  worker = await Tesseract.createWorker(lang, 1, {
    workerPath: 'lib/worker.min.js',
    corePath: 'lib/core',
    langPath: 'lib/lang',
    gzip: true,
    logger: (m) => {
      if (m.status === 'recognizing text') {
        $('bar').value = m.progress;
        $('status').textContent = `Lendo o texto… ${Math.round(m.progress * 100)}%`;
      } else if (m.status) {
        $('status').textContent = 'Preparando…';
      }
    },
  });
  workerLang = lang;
  return worker;
}

// Redimensiona e respeita a orientação EXIF da foto.
async function prepareImage(file) {
  const bmp = await createImageBitmap(file, { imageOrientation: 'from-image' });
  const scale = Math.min(1, MAX_SIDE / Math.max(bmp.width, bmp.height));
  const c = document.createElement('canvas');
  c.width = Math.round(bmp.width * scale);
  c.height = Math.round(bmp.height * scale);
  c.getContext('2d').drawImage(bmp, 0, 0, c.width, c.height);
  bmp.close();
  return c;
}

async function handleFile(file) {
  if (!file) return;
  $('work').hidden = false;
  $('result').hidden = true;
  $('bar').hidden = false;
  $('bar').value = 0;
  $('status').textContent = 'Carregando imagem…';
  $('preview').src = URL.createObjectURL(file);
  try {
    const canvas = await prepareImage(file);
    const w = await getWorker($('lang').value);
    const { data } = await w.recognize(canvas);
    const text = data.text.trim();
    $('text').value = text;
    $('result').hidden = false;
    $('status').textContent = text ? 'Pronto! Revise o texto abaixo.' : 'Nenhum texto encontrado. Tente uma foto mais nítida e bem iluminada.';
  } catch (e) {
    console.error(e);
    $('status').textContent = 'Erro ao ler a imagem: ' + (e.message || e);
  } finally {
    $('bar').hidden = true;
  }
}

['cam', 'gal'].forEach((id) => $(id).addEventListener('change', (e) => {
  handleFile(e.target.files[0]);
  e.target.value = ''; // permite escolher a mesma foto de novo
}));

function makeFile() {
  const stamp = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '-');
  return new File([$('text').value], `texto-${stamp}.txt`, { type: 'text/plain' });
}

$('save').addEventListener('click', () => {
  const f = makeFile();
  const a = document.createElement('a');
  a.href = URL.createObjectURL(f);
  a.download = f.name;
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 5000);
});

$('copy').addEventListener('click', async () => {
  try { await navigator.clipboard.writeText($('text').value); $('status').textContent = 'Texto copiado.'; }
  catch { $('text').select(); document.execCommand('copy'); $('status').textContent = 'Texto copiado.'; }
  $('work').hidden = false;
});

if (navigator.canShare && navigator.canShare({ files: [new File([''], 'a.txt', { type: 'text/plain' })] })) {
  $('share').hidden = false;
  $('share').addEventListener('click', () => navigator.share({ files: [makeFile()] }).catch(() => {}));
}

if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});
