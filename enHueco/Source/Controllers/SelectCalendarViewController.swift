//
//  SelectCalendarViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class SelectCalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    let eventStore = EKEventStore()
    var selectedCalendar: EKCalendar!

    @IBOutlet weak var calendarsTableView: UITableView!

    var calendars: [EKCalendar]?

    var importScheduleQuestionAlertView: UIAlertView?
    var generateFreeTimePeriodsQuestionAlertView: UIAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        calendarsTableView.dataSource = self
        calendarsTableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {

        navigationController!.isNavigationBarHidden = false

        checkCalendarAuthorizationStatus()
    }

    func checkCalendarAuthorizationStatus() {

        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if status == EKAuthorizationStatus.notDetermined {
            //First Time
            requestAccessToCalendar()
        } else if status == EKAuthorizationStatus.authorized {
            loadCalendars()
            calendarsTableView.reloadData()
        } else if status == EKAuthorizationStatus.restricted || status == EKAuthorizationStatus.denied {

        } else {
            UIAlertView(title: "Advertencia", message: "No nos has dado permiso para acceder a tus calendarios. Para arreglarlo debes ingresar a tus ajustes de privacidad en el dispositivo", delegate: nil, cancelButtonTitle: "OK, lo siento").show()
        }
    }

    func requestAccessToCalendar() {

        eventStore.requestAccess(to: .event) {
            (accessGranted, error) -> Void in

            if accessGranted {
                DispatchQueue.main.async {
                    self.loadCalendars()
                    self.calendarsTableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    UIAlertView(title: "Advertencia", message: "No nos has dado permiso para acceder a tus calendarios. Para arreglarlo debes ingresar a tus ajustes de privacidad en el dispositivo", delegate: nil, cancelButtonTitle: "OK, lo siento").show()
                }
            }
        }
    }

    func loadCalendars() {

        calendars = eventStore.calendars(for: EKEntityType.event)
        calendarsTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return calendars != nil ? calendars!.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSelectionCell")!

        let calendarName = calendars![indexPath.row].title
        cell.textLabel?.text = calendarName

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedCalendar = calendars![indexPath.row]

        importScheduleQuestionAlertView = UIAlertView(title: "Importar horario", message: "¿Estás seguro que deseas importar tu horario del calendario \"\(selectedCalendar.title)\"?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Importar")
        importScheduleQuestionAlertView!.show()

        /*let controller = storyboard!.instantiateViewControllerWithIdentifier("ImportScheduleFromLocalCalendarViewController") as! ImportScheduleFromLocalCalendarViewController
        controller.calendar = calendar
        
        navigationController!.pushViewController(controller, animated: true)*/
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {

        // TODO: Update implementation
        /*
        if alertView === importScheduleQuestionAlertView && buttonIndex == 1 {
            generateFreeTimePeriodsQuestionAlertView = UIAlertView(title: "Generar huecos", message: "¿Deseas que generemos los huecos que detectemos entre clases por ti? \n Recuerda que a menos de que agregues huecos a tu tiempo libre tus amigos no verán que estás en hueco.", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "No, Gracias", "Si")
            generateFreeTimePeriodsQuestionAlertView!.show()
        } else {
            EventsAndSchedulesManager.sharedManager.importScheduleFromCalendar(selectedCalendar, generateFreeTimePeriodsBetweenClasses: buttonIndex == 1) {
                success, error in

                guard success && error == nil else
                {
                    EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                    return
                }

                self.navigationController!.popViewControllerAnimated(true)
            }
        }
         */
    }
}
