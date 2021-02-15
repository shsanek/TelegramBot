//
//  File.swift
//  
//
//  Created by Шипин Александр on 12.02.2021.
//

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class DataStorage
{
	var chatState: ChatState = ChatState(actions: [], messages: []) {
		didSet {
			self.isNeedSave = true
			self.saveIfNeeded()
		}
	}

	private var isNeedSave: Bool = false
	private let path: String

	init(path: String) {
		self.path = path
		if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
		   let state = try? JSONDecoder().decode(ChatState.self, from: data)
		{
			self.chatState = state
		}
	}

	func updateMessage(id: Int64, updateBlock: (_ message: inout Messsage) -> Void) {
		guard let messageIndex = self.chatState.messages.firstIndex(where: { $0.identifier == id }) else {
			return
		}
		updateBlock(&self.chatState.messages[messageIndex])
	}

	func saveIfNeeded() {
		if self.isNeedSave {
			self.isNeedSave = false
			if let data = try? JSONEncoder().encode(self.chatState) {
				try? data.write(to: URL(fileURLWithPath: self.path))
			}
		}
	}
}
