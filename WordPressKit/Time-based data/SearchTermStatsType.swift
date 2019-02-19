public struct SearchTermStatsType {
    public let period: StatsPeriodUnit
    public let periodEndDate: Date

    public let totalSearchTermsCount: Int
    public let hiddenSearchTermsCount: Int
    public let otherSearchTermsCount: Int
    public let searchTerms: [SearchTerm]
}

public struct SearchTerm {
    public let term: String
    public let viewsCount: Int
}

extension SearchTermStatsType: TimeStatsProtocol {
    public static var pathComponent: String {
        return "stats/search-terms"
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let totalSearchTerms = jsonDictionary["total_search_terms"] as? Int,
            let hiddenSearchTerms = jsonDictionary["encrypted_search_terms"] as? Int,
            let otherSearchTerms = jsonDictionary["other_search_terms"] as? Int,
            let searchTermsDict = jsonDictionary["search_terms"] as? [[String: AnyObject]]
            else {
                return nil
        }

        let searchTerms: [SearchTerm] = searchTermsDict.compactMap {
            guard let term = $0["term"] as? String, let views = $0["views"] as? Int else {
                return nil
            }

            return SearchTerm(term: term, viewsCount: views)
        }


        self.periodEndDate = date
        self.period = period
        self.totalSearchTermsCount = totalSearchTerms
        self.hiddenSearchTermsCount = hiddenSearchTerms
        self.otherSearchTermsCount = otherSearchTerms
        self.searchTerms = searchTerms
    }

}

