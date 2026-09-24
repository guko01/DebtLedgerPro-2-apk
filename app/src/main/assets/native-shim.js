/* Injected by MainActivity after each page load.
   WebView ignores <a download> on blob: URLs, so route those to the native "save as" dialog. */
(function () {
  if (window.__dlpNativeShim) return;
  window.__dlpNativeShim = true;

  var blobs = {};
  var origCreate = URL.createObjectURL.bind(URL);
  URL.createObjectURL = function (obj) {
    var u = origCreate(obj);
    if (obj instanceof Blob) {
      blobs[u] = obj;
      setTimeout(function () { delete blobs[u]; }, 60000);
    }
    return u;
  };

  function send(name, blob) {
    var r = new FileReader();
    r.onloadend = function () {
      var s = String(r.result);
      AndroidBridge.saveFile(name, blob.type || 'application/octet-stream', s.substring(s.indexOf(',') + 1));
    };
    r.readAsDataURL(blob);
  }

  document.addEventListener('click', function (e) {
    var a = e.target && e.target.closest ? e.target.closest('a') : null;
    if (!a || !a.hasAttribute('download')) return;
    var href = a.href || '';
    if (href.indexOf('blob:') !== 0 && href.indexOf('data:') !== 0) return;
    e.preventDefault();
    e.stopPropagation();
    var name = a.getAttribute('download') || 'download';
    if (blobs[href]) send(name, blobs[href]);
    else fetch(href).then(function (r) { return r.blob(); }).then(function (b) { send(name, b); });
  }, true);
})();
