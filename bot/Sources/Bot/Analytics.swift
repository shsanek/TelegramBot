//
//  Analytics.swift
//  
//
//  Created by Шипин Александр on 14.02.2021.
//

import Foundation

extension Array where Element: IHasAutor {
	func filterAutor(with ids: [Int64]) -> Array<Element> {
		return self.filter({ ids.contains($0.autor.identifier) })
	}
	func groupWithAutor() -> [[Element]] {
		var groups = [Int64: [Element]]()
		self.forEach { (element) in
			if groups[element.autor.identifier] == nil {
				groups[element.autor.identifier] = []
			}
			groups[element.autor.identifier]?.append(element)
		}
		return groups.values.map({ $0 })
	}
}
