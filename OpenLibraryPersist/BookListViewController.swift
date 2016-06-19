//
//  BookListViewController.swift
//  OpenLibraryTable
//
//  Created by Veronica Marchan on 5/6/16.
//  Copyright © 2016 vmarchan. All rights reserved.
//

import UIKit
import CoreData

struct Libro {
    var titulo : String
    var autores : [String]
    var isbn : String
    var img_url : UIImage
    var error: String
    
    init(isbn: String, titulo: String, autores: [String], img_url: UIImage, error: String) {
        self.isbn = isbn
        self.titulo = titulo
        self.autores = autores
        self.img_url = img_url
        self.error = error
    }
}

class BookListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var searchView: NSLayoutConstraint!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    private var books : [Libro] = []
    let baseUrl = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    var searchedBook : Bool = false
    var searchError : Bool = false
    var errorBook : Libro = Libro(isbn: "", titulo: "", autores: [], img_url: UIImage(), error: "")
    var indexExistBook : Int?
    var existsISBN : Bool = false
    var isbnIndex: [String] = []
    var searchCode : String?
    
    var contexto : NSManagedObjectContext? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        self.addNewBook(addButton)
        self.textField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchedBook = false
        self.searchError = false
        self.existsISBN = false
        hideSearch()
        completeListBooks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func completeListBooks() -> Void {
        //Búsqueda en la base de datos.
        let bookEntity = NSEntityDescription.entityForName("Book", inManagedObjectContext: self.contexto!)
        let peticion = bookEntity?.managedObjectModel.fetchRequestTemplateForName("petBooks")
        
        do {
            let bookEntity = try self.contexto?.executeFetchRequest(peticion!)
            
            for book in bookEntity! {
                var newBook : Libro = Libro(isbn: "", titulo: "", autores: [], img_url: UIImage(), error: "")
                newBook.titulo = book.valueForKey("title") as! String
                let authors = book.valueForKey("tiene") as! Set<NSObject>
                var aux : [String] = []
                for author in authors {
                    let name = author.valueForKey("name") as! String
                    aux.append(name)
                }
                newBook.autores = aux
                newBook.isbn = book.valueForKey("isbn") as! String
                newBook.img_url = UIImage(data: book.valueForKey("cover") as! NSData)!
                
                self.books.append(newBook)
            }
        } catch let error as NSError {
            print ("Filed to load: \(error)")
            
        }
    }
    
    
    // MARK: - Hide/Show Search
    @IBAction func addNewBook(sender: UIBarButtonItem) {
        if self.searchView.constant == 0 {
            showSearch()
        }
    }
    
    func hideSearch() -> Void {
        self.searchView.constant = 0
        self.textField.hidden = true
        self.textField.text = ""
    }
    
    func showSearch() -> Void {
        self.searchView.constant = 71
        self.textField.hidden = false
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.searchAction(self)
        return false
    }

    func searchAction(sender: AnyObject) {
        
        
        self.view.endEditing(true)
        
        if (self.textField.text?.characters.count == 0) {
            let alert = UIAlertController(title: "¡Atención!", message: "Para realizar la búsqueda correctamente debe introducir el código ISBN", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic")
            }))
            
            presentViewController(alert, animated:true, completion:nil)
            
        } else {
            //            self.initStates()
            let isbn = self.textField.text
            let urls = self.baseUrl + isbn!
            let url = NSURL(string: urls)
            let session = NSURLSession.sharedSession()
            let bloque = { (datos : NSData?, resp : NSURLResponse?, error : NSError?) -> Void in
                
                if (error != nil) {
                    //alert
                    let alertError = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertError.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic")
                    }))
                    self.presentViewController(alertError, animated:true, completion:nil)
                } else {
                    let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
                    dispatch_async(dispatch_get_main_queue(), {
                        let data = texto?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                        
                        do {
                            var libro: Libro
                            libro = Libro(isbn: "", titulo: "", autores: [], img_url: UIImage(), error: "")
                            
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                            
                            let cont = json as! NSDictionary
                            
                            if let key = self.textField.text {
                                let bookKey = "ISBN:\(key)"
                                self.searchCode = bookKey
                                
                                //Búsqueda en la base de datos.
                                let bookEntity = NSEntityDescription.entityForName("Book", inManagedObjectContext: self.contexto!)
                                let peticion = bookEntity?.managedObjectModel.fetchRequestFromTemplateWithName("petBook", substitutionVariables: ["isbn": bookKey])
                                
                                do {
                                    let bookEntity2 = try self.contexto?.executeFetchRequest(peticion!)
                                    
                                    if (bookEntity2?.count > 0) {
                                        self.existsISBN = true
                                        libro.isbn = bookEntity!.valueForKey("isbn") as! String
                                        
                                        libro.titulo = bookEntity!.valueForKey("title") as! String
                                        let authors = bookEntity!.valueForKey("tiene") as! Set<NSObject>
                                        var aux : [String] = []
                                        for author in authors {
                                            let name = author.valueForKey("name") as! String
                                            aux.append(name)
                                        }
                                        libro.autores = aux
                                        libro.img_url = UIImage(data: bookEntity!.valueForKey("cover") as! NSData)!
                                    } else {
                                        //Get context if ISBN code exists
                                        if let cont1 = cont[bookKey] as? NSDictionary {
                                            self.existsISBN = true
                                            self.searchedBook = true
                                            let newbookEntity = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.contexto!)
                                            
                                            newbookEntity.setValue(bookKey, forKey: "isbn")
                                        
                                            //Set title if exists
                                            if let title : String = cont1["title"] as? String {
                                                newbookEntity.setValue(title, forKey: "title")
                                            }
                                            
                                            //Set authors list if exist
                                            if let cont2 = cont1["authors"] as? NSArray {
                                                newbookEntity.setValue(self.createAuthorsEntity(cont2 ), forKey: "tiene")
//                                                newbookEntity.setValue(self.createAuthorsEntity(cont2 as! [String]), forKey: "tiene")
                                            }
                                            
                                            //Set image if exists
                                            if let cont3 = cont1["cover"] as? NSDictionary {
                                                if let largeCover = cont3["large"] as? String {
                                                    if let imgURL = NSURL(string: largeCover) {
                                                        if let data = NSData(contentsOfURL: imgURL) {
                                                            newbookEntity.setValue(UIImage(data: data)!, forKey: "cover")
                                                        }
                                                    }
                                                    
                                                } else if let mediumCover = cont3["medium"] as? String {
                                                    if let imgURL = NSURL(string: mediumCover) {
                                                        if let data = NSData(contentsOfURL: imgURL) {
                                                            newbookEntity.setValue(UIImage(data: data)!, forKey: "cover")
                                                        }
                                                    }
                                                    
                                                } else if let smallCover = cont3["small"] as? String {
                                                    if let imgURL = NSURL(string: smallCover) {
                                                        if let data = NSData(contentsOfURL: imgURL) {
                                                            newbookEntity.setValue(UIImage(data: data)!, forKey: "cover")
                                                        }
                                                    }
                                                    
                                                } else {
                                                    newbookEntity.setValue(NSData(data:UIImageJPEGRepresentation(UIImage(named: "no-disponible")!, 1.0)!), forKey: "cover")
                                                }
                                            } else {
                                                newbookEntity.setValue(NSData(data:UIImageJPEGRepresentation(UIImage(named: "no-disponible")!, 1.0)!), forKey: "cover")
                                            }
                                        } else {
                                            self.existsISBN = false
                                        }
                                    }
                                    self.completeListBooks()
                                    self.performSegueWithIdentifier("BookDetailSegue", sender: self)
                                    self.tableView.reloadData()

                                } catch let error as NSError {
                                    print ("Filed to load: \(error)")
                                }
                            }
                            
                        } catch let error as NSError {
                            print ("Filed to load: \(error)")
                        }
                    })
                    
                }
            }
            let dt = session.dataTaskWithURL(url!, completionHandler:bloque)
            dt.resume()
        }
        
    }

    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.books.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celda", forIndexPath: indexPath) as! BookTableViewCell
        
        if !self.books[indexPath.row].titulo.isEmpty {
            cell.textLabel?.text = self.books[indexPath.row].titulo
        } else {
            cell.textLabel?.text = self.books[indexPath.row].isbn
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.existsISBN = true
        self.performSegueWithIdentifier("BookDetailSegue", sender: self)
    }
    
    func createAuthorsEntity(authors:NSArray) -> Set<NSObject> {
        var entidades = Set<NSObject>()
        
        for author in authors {
            let authorEntity = NSEntityDescription.insertNewObjectForEntityForName("Author", inManagedObjectContext: self.contexto!)
            authorEntity.setValue(author.valueForKey("name"), forKey: "name")
            entidades.insert(authorEntity)
        }
        return entidades
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "BookDetailSegue" {
            let bookDetailView = segue.destinationViewController as! BookDetailViewController
            
            
            if self.searchedBook {
                for book in self.books {
                    if (book.isbn.rangeOfString(self.textField.text!) != nil){
                        bookDetailView.libro = book
                    }
                }
            } else {
                if self.existsISBN {
                    let index = self.tableView.indexPathForSelectedRow
                    bookDetailView.libro = self.books[(index?.row)!]
                } 
            }
        }
        
        self.hideSearch()

    }
    

}
