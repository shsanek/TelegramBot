//
//  File.swift
//  
//
//  Created by Шипин Александр on 14.02.2021.
//

internal struct AppConfig: Codable {
	let httpsPort: Int
	let httpPort: Int
	let token: String
	let mainChat: Int64
	let ip: String
	let dataBase: String
	let maxConnections: Int
}
