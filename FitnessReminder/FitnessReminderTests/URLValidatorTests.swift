import Testing
@testable import FitnessReminder

struct URLValidatorTests {

    // MARK: - Instagram

    @Test func test_validate_instagramURL_returnsTrue() {
        #expect(URLValidator.isValid("https://www.instagram.com/reel/abc123/"))
    }

    @Test func test_validate_instagramURLWithoutWWW_returnsTrue() {
        #expect(URLValidator.isValid("https://instagram.com/p/abc123/"))
    }

    // MARK: - YouTube

    @Test func test_validate_youtubeURL_returnsTrue() {
        #expect(URLValidator.isValid("https://www.youtube.com/watch?v=abc123"))
    }

    @Test func test_validate_youtubeShortURL_returnsTrue() {
        #expect(URLValidator.isValid("https://youtu.be/abc123"))
    }

    @Test func test_validate_youtubeMobileURL_returnsTrue() {
        #expect(URLValidator.isValid("https://m.youtube.com/watch?v=abc123"))
    }

    // MARK: - Invalid

    @Test func test_validate_emptyString_returnsFalse() {
        #expect(!URLValidator.isValid(""))
    }

    @Test func test_validate_unsupportedDomain_returnsFalse() {
        #expect(!URLValidator.isValid("https://twitter.com/example"))
    }

    @Test func test_validate_malformedURL_returnsFalse() {
        #expect(!URLValidator.isValid("not a url"))
    }

    @Test func test_validate_plainText_returnsFalse() {
        #expect(!URLValidator.isValid("instagram"))
    }
}
