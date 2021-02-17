//
//  DataController.swift
//  
//
//  Created by Шипин Александр on 12.02.2021.
//

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class DataController {

	private let dataStorage: DataStorage
	private let workQueue = DispatchQueue(label: "work")

	init(dataStorage: DataStorage) {
		self.dataStorage = dataStorage
	}

	func getMessage(messageId: Int64, complite: @escaping (Messsage?) -> Void) {
		self.workQueue.sync {
			let message = self.dataStorage.chatState.messages.first(where: {  $0.identifier == messageId })
			complite(message)
		}
	}

	func sendMessage(messageId: Int64, chatId: Int64, date: Int64, autor: Autor, complite: @escaping (Messsage) -> Void) {
		workQueue.sync {
			var message = Messsage(date: date, chatId: chatId, identifier: messageId, autor: autor, appraisalContainer: [])
			message.appraisalContainer.append(AppraisalContainer(autor: autor, value: .crown))
			self.dataStorage.chatState.messages.append(message)
			self.dataStorage.chatState.actions.append(Action(date: date, autor: autor,
																messageIdentifier: messageId,
																type: .addedMessage))
			complite(message)
		}
	}

	func estimate(messageId: Int64, autor: Autor, date: Int64, appraisal: Appraisal, complite: @escaping (Messsage?) -> Void) {
		self.workQueue.sync {
			var result: Messsage? = nil
			var action: Action?
			self.dataStorage.updateMessage(id: messageId) { (message) in
				let container = message.appraisalContainer.first(where: { $0.autor.identifier == autor.identifier })
				message.appraisalContainer.removeAll(where: { $0.autor.identifier == autor.identifier })

				if container?.value == appraisal {
					action = Action(date: date, autor: autor, messageIdentifier: messageId, type: .deletedRating)
				} else {
					if container != nil {
						action = Action(date: date, autor: autor, messageIdentifier: messageId, type: .updateRating)

					} else {
						action = Action(date: date, autor: autor, messageIdentifier: messageId, type: .addedRating)
					}
					message.appraisalContainer.append(AppraisalContainer(autor: autor, value: appraisal))
				}
				result = message
			}
			if let action = action {
				self.dataStorage.chatState.actions.append(action)
			}
			complite(result)
		}
	}
}
