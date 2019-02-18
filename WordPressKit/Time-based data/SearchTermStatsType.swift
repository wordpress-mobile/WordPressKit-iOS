struct SearchTermStatsType {
    let period: StatsPeriodUnit
    let periodEndDate: Date

    let totalSearchTermsCount: Int
    let hiddenSearchTermsCount: Int
    let otherSearchTermsCount: Int
    let searchTerms: [SearchTerm]
}


extension SearchTermStatsType: TimeStatsProtocol {
    static var pathComponent: String {
        return "stats/search-terms"
    }

    init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let days = jsonDictionary["days"] as? [String: AnyObject],
            let firstKey = days.keys.first,
            let firstDay = days[firstKey] as? [String: AnyObject],
            let totalSearchTerms = firstDay["total_search_terms"] as? Int,
            let hiddenSearchTerms = firstDay["encrypted_search_terms"] as? Int,
            let otherSearchTerms = firstDay["other_search_terms"] as? Int,
            let searchTermsDict = firstDay["search_terms"] as? [[String: AnyObject]]
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

public struct SearchTerm {
    let term: String
    let viewsCount: Int
}
