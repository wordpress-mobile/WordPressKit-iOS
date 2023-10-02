import Foundation
import XCTest

@testable import WordPressKit

final class AllDomainsResultDomainTests: XCTestCase {

    // MARK: - Properties

    private let dateFormatter = ISO8601DateFormatter()

    // MARK: - Tests

    func testDecoding1() throws {
        // Given
        let decoder = makeDecoder()
        let input = try makeInput()

        // When
        let output = try decoder.decode(Domain.self, from: input)

        // Then
        let expectedOutput = makeDomain()
        assertEqual(output, otherDomain: expectedOutput)
    }

    // MARK: - Helpers

    private func assertEqual(_ domain: Domain, otherDomain: Domain) {
        XCTAssertEqual(domain.domain, otherDomain.domain)
        XCTAssertEqual(domain.blogId, otherDomain.blogId)
        XCTAssertEqual(domain.blogName, otherDomain.blogName)
        XCTAssertEqual(domain.type, otherDomain.type)
        XCTAssertEqual(domain.isDomainOnlySite, otherDomain.isDomainOnlySite)
        XCTAssertEqual(domain.isWpcomStagingDomain, otherDomain.isWpcomStagingDomain)
        XCTAssertEqual(domain.registrationDate, otherDomain.registrationDate)
        XCTAssertEqual(domain.expiryDate, otherDomain.expiryDate)
        XCTAssertEqual(domain.wpcomDomain, otherDomain.wpcomDomain)
        XCTAssertEqual(domain.currentUserIsOwner, otherDomain.currentUserIsOwner)
        XCTAssertEqual(domain.siteSlug, otherDomain.siteSlug)
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func makeDomain(
        domain: String = Defaults.domain,
        blogId: Int = Defaults.blogId,
        blogName: String = Defaults.blogName,
        type: String = "redirect",
        isDomainOnlySite: Bool = Defaults.isDomainOnlySite,
        isWpcomStagingDomain: Bool = Defaults.isWpcomStagingDomain,
        hasRegistration: Bool = Defaults.hasRegistration,
        registrationDate: String? = Defaults.registrationDate,
        expiryDate: String? = Defaults.expiryDate,
        wpcomDomain: Bool = Defaults.wpcomDomain,
        currentUserIsOwner: Bool? = Defaults.currentUserIsOwner,
        siteSlug: String = Defaults.siteSlug
    ) -> Domain {
        return .init(
            domain: domain,
            blogId: blogId,
            blogName: blogName,
            type: type,
            isDomainOnlySite: isDomainOnlySite,
            isWpcomStagingDomain: isWpcomStagingDomain,
            hasRegistration: hasRegistration,
            registrationDate: dateFormatter.date(from: registrationDate ?? ""),
            expiryDate: dateFormatter.date(from: expiryDate ?? ""),
            wpcomDomain: wpcomDomain,
            currentUserIsOwner: currentUserIsOwner,
            siteSlug: siteSlug
        )
    }

    private func makeInput(
        domain: String = Defaults.domain,
        blogId: Int = Defaults.blogId,
        blogName: String = Defaults.blogName,
        type: String = "redirect",
        isDomainOnlySite: Bool = Defaults.isDomainOnlySite,
        isWpcomStagingDomain: Bool = Defaults.isWpcomStagingDomain,
        hasRegistration: Bool = Defaults.hasRegistration,
        registrationDate: String? = Defaults.registrationDate,
        expiryDate: String? = Defaults.expiryDate,
        wpcomDomain: Bool = Defaults.wpcomDomain,
        currentUserIsOwner: Bool? = Defaults.currentUserIsOwner,
        siteSlug: String = Defaults.siteSlug
    ) throws -> Data {
        let json: [String: Any] = [
            "domain": domain,
            "blog_id": blogId,
            "blog_name": blogName,
            "type": type,
            "is_domain_only_site": isDomainOnlySite,
            "is_wpcom_staging_domain": isWpcomStagingDomain,
            "has_registration": hasRegistration,
            "registration_date": registrationDate as Any,
            "expiry": expiryDate as Any,
            "wpcom_domain": wpcomDomain,
            "current_user_is_owner": currentUserIsOwner as Any,
            "site_slug": siteSlug
        ]
        return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }

    private enum Defaults {
        static let domain = "example1.com"
        static let blogId: Int = 12345
        static let blogName: String = "Example Blog 1"
        static let isDomainOnlySite: Bool = false
        static let isWpcomStagingDomain: Bool = false
        static let hasRegistration: Bool = true
        static let registrationDate: String? = "2022-01-01T00:00:00+00:00"
        static let expiryDate: String? = "2023-01-01T00:00:00+00:00"
        static let wpcomDomain: Bool = false
        static let currentUserIsOwner: Bool? = false
        static let siteSlug: String = "exampleblog1.wordpress.com"
    }

    typealias Domain = DomainsServiceRemote.AllDomainsResultDomain

}
