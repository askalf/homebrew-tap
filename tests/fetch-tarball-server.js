// For fetch-tarball.test.sh. /<n>/<name> answers 404 for the first n requests of that path, then the
// tarball's bytes. Writes the port it took to <dir>/port.
const http = require('http');
const fs = require('fs');

const dir = process.argv[2];
const seen = {};

http.createServer((req, res) => {
  const n = Number(req.url.split('/')[1]);
  seen[req.url] = (seen[req.url] || 0) + 1;
  if (seen[req.url] <= n) {
    res.statusCode = 404;
    res.end('not yet');
    return;
  }
  res.end('tarball-bytes');
}).listen(0, '127.0.0.1', function listening() {
  fs.writeFileSync(`${dir}/port`, String(this.address().port));
});
