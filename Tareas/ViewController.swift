//
//  ViewController.swift
//  Tareas
//
//  Created by mac16 on 10/05/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Variables
    var listaTareas = [Tarea]()
    
    //Conexiòn al contexto mara manipular DB
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var tablaTareas: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tablaTareas.delegate = self
        tablaTareas.dataSource = self
        
        leer()
    }

    @IBAction func agregarTarea(_ sender: UIBarButtonItem) {
        // Variable para guardar el nombre de la alerta
        var titulo = UITextField()
        
        let alerta = UIAlertController(title: "Agregar", message: "Tarea", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { (_) in
            //Crear nueva tarea
            let nuevaTarea = Tarea(context: self.contexto)
            nuevaTarea.titulo = titulo.text
            nuevaTarea.realizada = false
            
            //Agregar nueva tarea al arreglo de listaTareas para llenar la tabla
            self.listaTareas.append(nuevaTarea)
            
            self.guardar()
        }
        //Agregar el text Field a la alerta
        alerta.addTextField { (textFieldAlerta) in
            textFieldAlerta.placeholder = "Escribe tu nueva tarea"
            titulo=textFieldAlerta
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    func guardar(){
        do {
            try contexto.save()
        } catch {
            print("Error al guardar en coredata: \(error.localizedDescription)")
        }
        self.tablaTareas.reloadData()
    }
    
    func leer(){
        let solicitud: NSFetchRequest<Tarea> = Tarea.fetchRequest()
        do {
            //Tratar de asignar al arreglo de tareas lo que arroje la solicitud
            listaTareas = try contexto.fetch(solicitud)
        } catch {
            print("Error al leer datos de coredata: \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaTareas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        
        let tarea = listaTareas[indexPath.row]
        
        //Operador terniario
        celda.textLabel?.text = tarea.titulo
        celda.textLabel?.textColor = tarea.realizada ? .black : .blue
        
        celda.detailTextLabel?.text = tarea.realizada ? "Completada" : "Pendiente..."
        
        celda.accessoryType = tarea.realizada ? .checkmark : .none
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Si la tarea esta palomeada
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            //Si la celda no esta palomeada
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //Edicion de core data
        listaTareas[indexPath.row].realizada = !listaTareas[indexPath.row].realizada
        guardar()
        
        //Deseleccionar celda
        tablaTareas.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar = UIContextualAction(style: .normal, title: "Borrar") { (_, _, _) in
            self.contexto.delete(self.listaTareas[indexPath.row])
            self.listaTareas.remove(at: indexPath.row)
            
            self.guardar()
        }
        accionEliminar.image = UIImage(systemName: "trash.fill")
        accionEliminar.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
}
