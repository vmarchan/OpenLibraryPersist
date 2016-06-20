//
//  BookDetailViewController.swift
//  OpenLibraryTable
//
//  Created by Veronica Marchan on 5/6/16.
//  Copyright © 2016 vmarchan. All rights reserved.
//

import UIKit
//import CoreData

class BookDetailViewController: UIViewController {

    @IBOutlet var imgBook: UIImageView!
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var isbnCode: UILabel!
    @IBOutlet var bookAuthor: UILabel!
    @IBOutlet var errorText: UILabel!
    
    var libro: Libro? //= Libro(isbn: "", titulo: "", autores: [], img_url: UIImage(), error: "")
    var error : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imgBook.layer.shadowColor = UIColor.grayColor().CGColor
        self.imgBook.layer.shadowOpacity = 0.5
        self.imgBook.layer.shadowOffset = CGSizeZero
        self.imgBook.layer.shadowRadius = 5
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showBookInformation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showBookInformation() -> Void {
        
        if (self.libro != nil) {
            //show all information and hide error
            self.imgBook.hidden = false
            self.bookTitle.hidden = false
            self.bookAuthor.hidden = false
            self.isbnCode.hidden = false
            self.errorText.hidden = true
            
            self.imgBook.image = libro!.img_url
            self.bookTitle.text = libro!.titulo
            for author in libro!.autores{
                let name = author
                if ((self.bookAuthor.text?.isEmpty) != nil) {
                    self.bookAuthor.text = name
                } else {
                    self.bookAuthor.text = "\(self.bookAuthor.text), \(name)"
                }
            }
            self.isbnCode.text = self.libro!.isbn
        } else {
            //hide all information and show error
            self.imgBook.hidden = true
            self.bookTitle.hidden = true
            self.bookAuthor.hidden = true
            self.isbnCode.hidden = true
            self.errorText.hidden = false
            
            self.errorText.text = "El libro no se ha encontrado. Comprueba que el código ISBN es el correcto."
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
