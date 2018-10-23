//
//  DatePickerViewController.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 10/23/18.
//  Copyright © 2018 LetsHangLLC. All rights reserved.
//

import UIKit
import CVCalendar

class DatePickerViewController: UIViewController {

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
}
