import Foundation

internal struct AppConfig: Codable {
	let httpsPort: Int
	let httpPort: Int
	let token: String
	let mainChat: Int64
	let ip: String
	let dataBase: String
	let maxConnections: Int
}


let rootPath = "/serverBot"

func generateRunScript(appConfig: AppConfig) throws {
	let runScriptPath = "\(path)/run/run"
	let script = """
	kill $(lsof -t -i:\(appConfig.httpPort))
	kill $(lsof -t -i:\(appConfig.httpsPort))
	cd \(path)/run
	screen -dmS swift ./start-swift
	screen -dmS proxy ./start-node
	curl -F "url=https://\(appConfig.ip):\(appConfig.httpsPort)/\(appConfig.token)" -F "certificate=@\(path)/key/YOURPUBLIC.pem" -F "max_connections=\(appConfig.maxConnections)" https://api.telegram.org\(rootPath)\(appConfig.token)/setWebhook
	"""
	try script.data(using: .utf8)?.write(to: URL(fileURLWithPath: runScriptPath))
	print("generate \(runScriptPath)")
}

func generateSwiftRunScript(appConfig: AppConfig) throws {
	let runScriptPath = "\(path)/run/start-swift"
	let script = """
	NOW=$(date +"%Y-%m-%d_%H-%M-%S")
	LOG_PATH="\(appConfig.dataBase)/log/swift$NOW.log"
	cd ..\(rootPath)
	swift run Bot $PWD >$LOG_PATH 2>&1
	"""
	try script.data(using: .utf8)?.write(to: URL(fileURLWithPath: runScriptPath))
	print("generate \(runScriptPath)")
}

func generateNodeRunScript(appConfig: AppConfig) throws {
	let runScriptPath = "\(path)/run/start-node"
	let script = """
	cd ../proxy/
	node index.js >\(appConfig.dataBase)/log/node-last.log 2>&1
	"""
	try script.data(using: .utf8)?.write(to: URL(fileURLWithPath: runScriptPath))
	print("generate \(runScriptPath)")
}

func generateProxyScript(appConfig: AppConfig) throws {
	let proxyScriptPath = "\(path)/proxy/index.js"
	let script = """
	var httpProxy = require('http-proxy');
	var fs = require('fs');
	httpProxy.createServer({
		target: {
			host: 'localhost',
			port: \(appConfig.httpPort)
		},
		ssl: {
			key: fs.readFileSync('\(path)/key/YOURPRIVATE.key', 'utf8'),
			cert: fs.readFileSync('\(path)/key/YOURPUBLIC.pem', 'utf8')
		}
	}).listen(\(appConfig.httpsPort));
	"""
	try script.data(using: .utf8)?.write(to: URL(fileURLWithPath: proxyScriptPath))
	print("generate \(proxyScriptPath)")
}

enum AppType: String {
	case test
	case product
}

let path = CommandLine.arguments[1] + "/.."
guard let type = AppType.init(rawValue: CommandLine.arguments[2]) else {
	fatalError("incorect type")
}
let configPath = type == .test ? "\(rootPath)/config/test-config.json" : "\(rootPath)/config/prod-config.json"
guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
	  let config = try? JSONDecoder().decode(AppConfig.self, from: data) else {
	fatalError("config not load from path \(configPath)")
}

try JSONEncoder().encode(config).write(to: URL(fileURLWithPath: "\(path)\(rootPath)/config.json"))
try generateRunScript(appConfig: config)
try generateProxyScript(appConfig: config)
try generateNodeRunScript(appConfig: config)
try generateSwiftRunScript(appConfig: config)

