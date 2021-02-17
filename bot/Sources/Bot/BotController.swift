//
//  File.swift
//  
//
//  Created by Шипин Александр on 14.02.2021.
//

import TelegramAPI
import Foundation

final class BotController
{
	private let dataController: DataController

	init(dataController: DataController) {
		self.dataController = dataController
	}

	func addPhoto(photoIdentifier: String, autor: Autor) {
		let message = TelegramSendPhotoInput(chatId: .integer(identifier: cMainChat),
											 photo: .identifier(identifier: photoIdentifier),
											 caption: autor.name)
		api.sendPhoto(message, completionHandler: { (result) in
			switch result {
			case .completion(let object):
				if let obj = object.result {
					self.dataController.sendMessage(messageId: obj.messageId, chatId: cMainChat, date: obj.date, autor: autor) {
						self.update(message: $0)
					}
				}
			default:
				break
			}
		})
	}

	func addVideo(videoIdentifier: String, autor: Autor) {
		let message = TelegramSendVideoInput(chatId: .integer(identifier: cMainChat),
											 video: .identifier(identifier: videoIdentifier),
											 caption: autor.name)
		api.sendVideo(message, completionHandler: { (result) in
			switch result {
			case .completion(let object):
				if let obj = object.result {
					self.dataController.sendMessage(messageId: obj.messageId, chatId: cMainChat, date: obj.date, autor: autor) {
						self.update(message: $0)
					}
				}
			default:
				break
			}
		})
	}

	func createButton(for message: Messsage, appraisal: Appraisal) -> TelegramInlineKeyboardButton {
		let count = message.appraisalContainer.filter({ $0.value == appraisal }).count
		let countString = (count == 0) ? "" : "\(count)"
		return TelegramInlineKeyboardButton(text: "\(symbolForAppraisal(appraisal))\(countString)", callbackData: appraisal.rawValue)
	}

	func symbolForAppraisal(_ appraisal: Appraisal) -> String {
		switch appraisal {
		case .crown:  return "👑"
		case .mountain: return "⛰"
		case .shit: return "💩"
		case .web: return "🕸"
		case .yell: return "🗣"
		}
	}

	func update(message: Messsage) {
		var buttons = [TelegramInlineKeyboardButton]()
		buttons.append(createButton(for: message, appraisal: .crown))
		buttons.append(createButton(for: message, appraisal: .mountain))
		buttons.append(createButton(for: message, appraisal: .yell))
		buttons.append(createButton(for: message, appraisal: .shit))
		buttons.append(createButton(for: message, appraisal: .web))
		let markup = TelegramInlineKeyboardMarkup(inlineKeyboard: [buttons])
		let edit = TelegramEditMessageReplyMarkupInput(chatId: .integer(identifier: message.chatId),
													   messageId: message.identifier,
													   inlineMessageId: nil,
													   replyMarkup: markup)
		api.editMessageReplyMarkup(edit) { result in
			print(result)
		}
	}

	func sendInfoForMessage(message: Messsage, in chat: TelegramInteger) {
		var appraisals = [Appraisal: String]()
		for appraisal in message.appraisalContainer {
			if appraisals[appraisal.value] == nil {
				appraisals[appraisal.value] = ""
			} else {
				appraisals[appraisal.value]? +=  ", "
			}
			appraisals[appraisal.value]? += appraisal.autor.name
		}
		let result = appraisals.reduce("", { $0 + self.symbolForAppraisal($1.key) + ": " + $1.value + ";\n" })
		api.sendMessage(TelegramSendMessageInput(chatId: .integer(identifier: chat),
												 text: result),
						completionHandler: { _ in })
	}

	func update(with items: [TelegramUpdate]) {
		for item in items {
			if let message = item.message,
			   let from = message.from,
			   from.id == message.chat.id {
				var name = from.firstName
				name += (from.lastName.flatMap({" \($0)"}) ?? "")
				let autor = Autor(name: name, identifier: from.id)
				if let forwardFromMessageId = message.forwardFromMessageId {
					var result = false
					self.dataController.getMessage(messageId: forwardFromMessageId) { (message) in
						if let message = message {
							result = true
							self.sendInfoForMessage(message: message, in: from.id)
						}
					}
					if result {
						return
					}
				}
				if let photos = message.photo,
				   let photo = photos.max(by: { $0.height > $1.height }) {
					addPhoto(photoIdentifier: photo.fileId, autor: autor)
				}
				if let video = message.video {
					addPhoto(photoIdentifier: video.fileId, autor: autor)
				}
			}
			if let callBack = item.callbackQuery,
			   let message = callBack.message,
			   let data = callBack.data {
				var name = callBack.from.firstName
				name += (callBack.from.lastName.flatMap({" \($0)"}) ?? "")
				let autor = Autor(name: name, identifier: callBack.from.id)
				if let appraisal = Appraisal(rawValue: data) {
					dataController.estimate(messageId: message.messageId,
											autor: autor,
											date: Int64(Date().timeIntervalSince1970),
											appraisal: appraisal) { res in
						if let message = res {
							self.update(message: message)
						}
					}
				}
			}
		}
	}
}
