import Foundation

struct Movie: Codable {
    var documentID: String?
    var movieID: Int
    var title: String
    var studio: String
    var genres: [String]
    var directors: [String]
    var writers: [String]
    var actors: [String]
    var year: Int
    var length: Int
    var shortDescription: String
    var mpaRating: String
    var criticsRating: Double
}