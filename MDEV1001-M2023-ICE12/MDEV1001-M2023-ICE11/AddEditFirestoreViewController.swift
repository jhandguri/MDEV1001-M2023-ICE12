import UIKit
import Firebase

class AddEditFirestoreViewController: UIViewController {

    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Movie Fields
    @IBOutlet weak var movieIDTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var studioTextField: UITextField!
    @IBOutlet weak var genresTextField: UITextField!
    @IBOutlet weak var directorsTextField: UITextField!
    @IBOutlet weak var writersTextField: UITextField!
    @IBOutlet weak var actorsTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mpaRatingTextField: UITextField!
    @IBOutlet weak var criticsRatingTextField: UITextField!
    
    var movie: Movie?
    var movieViewController: FirestoreCRUDViewController?
    var movieUpdateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let movie = movie {
            // Editing existing movie
            movieIDTextField.text = "\(movie.movieID)"
            titleTextField.text = movie.title
            studioTextField.text = movie.studio
            genresTextField.text = movie.genres.joined(separator: ", ")
            directorsTextField.text = movie.directors.joined(separator: ", ")
            writersTextField.text = movie.writers.joined(separator: ", ")
            actorsTextField.text = movie.actors.joined(separator: ", ")
            lengthTextField.text = "\(movie.length)"
            yearTextField.text = "\(movie.year)"
            descriptionTextView.text = movie.shortDescription
            mpaRatingTextField.text = movie.mpaRating
            criticsRatingTextField.text = "\(movie.criticsRating)"
            
            AddEditTitleLabel.text = "Edit Movie"
            UpdateButton.setTitle("Update", for: .normal)
        } else {
            AddEditTitleLabel.text = "Add Movie"
            UpdateButton.setTitle("Add", for: .normal)
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateButton_Pressed(_ sender: UIButton) {
        guard
              let movieIDString = movieIDTextField.text,
              let movieID = Int(movieIDString),
              let title = titleTextField.text,
              let studio = studioTextField.text,
              let genres = genresTextField.text,
              let directors = directorsTextField.text,
              let writers = writersTextField.text,
              let actors = actorsTextField.text,
              let yearString = yearTextField.text,
              let year = Int(yearString),
              let lengthString = lengthTextField.text,
              let length = Int(lengthString),
              let description = descriptionTextView.text,
              let mpaRating = mpaRatingTextField.text,
              let criticsRatingString = criticsRatingTextField.text,
              let criticsRating = Double(criticsRatingString) else {
            print("Invalid data")
            return
        }

        let db = Firestore.firestore()

        if let movie = movie {
            // Update existing movie
            guard let documentID = movie.documentID else {
                print("Document ID not available.")
                return
            }

            let movieRef = db.collection("movies").document(documentID)
            movieRef.updateData([
                "movieID": movieID,
                "title": title,
                "studio": studio,
                "genres": genres.components(separatedBy: ", "),
                "directors": directors.components(separatedBy: ", "),
                "writers": writers.components(separatedBy: ", "),
                "actors": actors.components(separatedBy: ", "),
                "year": year,
                "length": length,
                "shortDescription": description,
                "mpaRating": mpaRating,
                "criticsRating": criticsRating
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating movie: \(error)")
                } else {
                    print("Movie updated successfully.")
                    self?.dismiss(animated: true) {
                        self?.movieUpdateCallback?()
                    }
                }
            }
        } else {
            // Add new movie
            let newMovie 	= [
                "movieID": Int(movieID),
                "title": title,
                "studio": studio,
                "genres": genres.components(separatedBy: ", "),
                "directors": directors.components(separatedBy: ", "),
                "writers": writers.components(separatedBy: ", "),
                "actors": actors.components(separatedBy: ", "),
                "year": Int(year),
                "length": Int(length),
                "shortDescription": description,
                "mpaRating": mpaRating,
                "criticsRating": Double(criticsRating)
            ] as [String : Any]

            var ref: DocumentReference? = nil
            ref = db.collection("movies").addDocument(data: newMovie) { [weak self] error in
                if let error = error {
                    print("Error adding movie: \(error)")
                } else {
                    print("Movie added successfully.")
                    self?.dismiss(animated: true) {
                        self?.movieUpdateCallback?()
                    }
                }
            }
        }
    }
}