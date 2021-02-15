//
//  Model.swift
//  
//
//  Created by Шипин Александр on 12.02.2021.
//

public protocol IHasAutor
{
	var autor: Autor { get }
}

public protocol IHasDate
{
	var date: Int64 { get }
}

public struct Autor
{
	public var name: String
	public var identifier: Int64
}
extension Autor: Codable { }

public struct Messsage: IHasAutor, IHasDate
{
	public var date: Int64
	public var chatId: Int64
	public var identifier: Int64
	public var autor: Autor
	public var appraisalContainer: [AppraisalContainer]
}
extension Messsage: Codable { }

public struct AppraisalContainer
{
	public var autor: Autor
	public var value: Appraisal
}
extension AppraisalContainer: Codable { }

public enum Appraisal: String
{
	case crown
	case mountain
	case yell
	case shit
	case web
}
extension Appraisal: Codable { }

public enum ActionType: String
{
	case addedMessage
	case addedRating
	case updateRating
	case deletedRating
}
extension ActionType: Codable { }

public struct Action: IHasAutor, IHasDate
{
	public var date: Int64
	public var autor: Autor
	public var messageIdentifier: Int64
	public var type: ActionType
}
extension Action: Codable { }

public struct ChatState
{
	public var actions: [Action]
	public var messages: [Messsage]
}
extension ChatState: Codable { }
