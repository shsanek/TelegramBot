	var httpProxy = require('http-proxy');
	var fs = require('fs');
	//
	// Create the HTTPS proxy server in front of a HTTP server
	//
	httpProxy.createServer({
		target: {
			host: 'localhost',
			port: 8081
		},
		ssl: {
			key: fs.readFileSync('/Users/ashipin/TelegramBot/generate/../key/YOURPRIVATE.key', 'utf8'),
			cert: fs.readFileSync('/Users/ashipin/TelegramBot/generate/../key/YOURPUBLIC.pem', 'utf8')
		}
	}).listen(8443);