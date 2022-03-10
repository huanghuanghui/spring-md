const http = require('http');
const os = require('os');
console.log('kubia server is starting ....');

var handler = function(req,rep){
    console.log("Recei ved request from "+ req.connection. remoteAddress);
    rep.writeHead(200);
    rep.end("youne hit "+os.hostname());
};

var www=http.createServer(handler);
www.listen(8080);