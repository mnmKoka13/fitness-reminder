import Testing
@testable import FitnessReminder

struct VideoMetadataFetcherTests {
    private let fetcher = VideoMetadataFetcher()

    // MARK: - 名前付きエンティティ

    @Test func test_decode_ampersand() {
        #expect(fetcher.decodeHTMLEntities("A &amp; B") == "A & B")
    }

    @Test func test_decode_lessThanGreaterThan() {
        #expect(fetcher.decodeHTMLEntities("&lt;div&gt;") == "<div>")
    }

    @Test func test_decode_quotAndApos() {
        #expect(fetcher.decodeHTMLEntities("&quot;Hello&quot; &#39;World&#39;") == "\"Hello\" 'World'")
    }

    // MARK: - 数値エンティティ（10進数）

    @Test func test_decode_decimalEntity_japanese() {
        // &#26085;&#26412;&#35486; = 日本語
        #expect(fetcher.decodeHTMLEntities("&#26085;&#26412;&#35486;") == "日本語")
    }

    @Test func test_decode_decimalEntity_mixed() {
        #expect(fetcher.decodeHTMLEntities("&#65;&#66;&#67;") == "ABC")
    }

    // MARK: - 数値エンティティ（16進数）

    @Test func test_decode_hexEntity_japanese() {
        // &#x65E5;&#x672C;&#x8A9E; = 日本語
        #expect(fetcher.decodeHTMLEntities("&#x65E5;&#x672C;&#x8A9E;") == "日本語")
    }

    @Test func test_decode_hexEntity_uppercase() {
        #expect(fetcher.decodeHTMLEntities("&#X41;") == "&#X41;")  // X大文字は対象外
    }

    // MARK: - エンティティなし

    @Test func test_decode_noEntities_returnsOriginal() {
        let title = "運動動画タイトル"
        #expect(fetcher.decodeHTMLEntities(title) == title)
    }

    @Test func test_decode_emptyString_returnsEmpty() {
        #expect(fetcher.decodeHTMLEntities("") == "")
    }

    // MARK: - 複合

    @Test func test_decode_mixedEntities() {
        #expect(fetcher.decodeHTMLEntities("【&#26085;&#26412;&#35486;】A &amp; B") == "【日本語】A & B")
    }
}
