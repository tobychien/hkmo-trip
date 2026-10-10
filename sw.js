/* 離線快取：App 本體走「先網路、失敗用快取」，字型與函式庫走「先快取」 */
const V="hkmo-v1";
const SHELL=["./","./index.html","./config.js","./manifest.webmanifest","./icons/icon-180.png","./icons/icon-192.png"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(V).then(c=>c.addAll(SHELL)).then(()=>self.skipWaiting()))});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==V).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener("fetch",e=>{
  const u=new URL(e.request.url);
  if(e.request.method!=="GET")return;
  if(u.origin===location.origin){
    e.respondWith(fetch(e.request).then(r=>{const cp=r.clone();caches.open(V).then(c=>c.put(e.request,cp));return r}).catch(()=>caches.match(e.request).then(r=>r||caches.match("./index.html"))));return}
  if(/fonts\.(googleapis|gstatic)\.com|cdn\.jsdelivr\.net|cdnjs\.cloudflare\.com/.test(u.host)){
    e.respondWith(caches.match(e.request).then(hit=>hit||fetch(e.request).then(r=>{const cp=r.clone();caches.open(V).then(c=>c.put(e.request,cp));return r})))}
});
