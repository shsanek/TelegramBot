//
//  File.swift
//  
//
//  Created by Шипин Александр on 12.02.2021.
//

import TelegramAPI
import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

print("start")
print(CommandLine.arguments)
let dataConfig = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1] + "db/data.json"))
print(String(data: dataConfig, encoding: .utf8) ?? "")
let config = try JSONDecoder().decode(AppConfig.self, from: dataConfig)
let cMainChat: TelegramInteger = config.mainChat
print(cMainChat)
let api = TelegramAPI(token: config.token)
let path: String? = "/Users/ashipin/Desktop/myapp/data.json"
let dataController = DataController(dataStorage: DataStorage(path: path ?? (config.dataBase + "/db/data.json")))
print((config.dataBase + "/db/data.json"))
let botController = BotController(dataController: dataController)

import Swifter

let http = HttpServer()
http["/\(config.token)"] = { (result) in
	let data = Data(result.body)
	let json = try? JSONDecoder().decode(TelegramUpdate.self, from: data)
	print(String(data: data, encoding: .utf8) ?? "empty input")
	json.flatMap({ botController.update(with: [$0]) })
	return .ok(HttpResponseBody.html("ok"))
}
try http.start(in_port_t(config.httpPort))

api.sendMessage(TelegramSendMessageInput(chatId: .integer(identifier: cMainChat), text: "Start api"), completionHandler: { _ in })
while true { sleep(1000) }

