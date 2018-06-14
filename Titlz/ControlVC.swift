//
//  ControlVC.swift
//  Titlz
//
//  Created by Kobus Swart on 2018/06/09.
//  Copyright © 2018 Kobus Swart. All rights reserved.
//
import CoreBluetooth
import UIKit
import CoreMotion
import AVFoundation

class ControlVC: UIViewController{
    
    
    
    /* Buttons on View */
    @IBOutlet var btn_NewGame: UIButton!                        // new game button to start ne game
    
    /* Views on View */
    @IBOutlet var view_BigCircle: UIView!                       // view big outer circle
    @IBOutlet var view_MediumCircle: UIView!                    // view medium inner circle
    @IBOutlet var view_SmallCircle: UIView!                     // view small circle that tracts tilt of the phone
    @IBOutlet var view_lb_Countdown: UIView!                    // view that contains lb_Countdown
    
    /* Labels on View */
    @IBOutlet var lb_Countdown: UILabel!                        // lable that displays the countdown timer and other information
    @IBOutlet var lb_YourScore: UILabel!                        // lable that displays score of the user of the phone
    @IBOutlet var lb_OpponentScore: UILabel!                    // lable that display score of the challenger
    @IBOutlet var lb_YourName: UILabel!                         // lable that displays the Nickname of the user of the phopne
    @IBOutlet var lb_OpponentName: UILabel!                     // lable that displays the Nickname of the challenger
    
    /* Images on View */
    @IBOutlet var image_up: UIImageView!                        // image of the up arrow
    @IBOutlet var image_down: UIImageView!                      // image of the down arrow
    @IBOutlet var image_left: UIImageView!                      // image of the left arrow
    @IBOutlet var image_right: UIImageView!                     // image of the right arrow
    
    
    /* Global variable of ControlVC ViewController */
    var player: AVAudioPlayer?                                  // var to play audio
    var motionManager: CMMotionManager!                         // var to track motion and tilt of phone
    var winnerorlosser = 0                                      // var to indicate if player is the winner or the losser of the round
    var indicate_winnerorlosser = 0                             // var to act as counter in seconds to display if player is the winner or the losser of the round
    var deviceUUID : UUID?                                      // var that contains the uuid of the selectedPeripheral
    var deviceAttributes : String = ""                          // var that contains the attributes of the selectedPeripheral
    var yourName : String = ""                                  // var that contains the Nickname of the user of the phone
    var selectedPeripheral : CBPeripheral?                      // var that contains info about the selectedPeripheral
    var centralManager: CBCentralManager?                       // var that contains info about the centralManager
    var peripheralManager = CBPeripheralManager()               // var that contains info about the peripheralManager
    var waitingforchallenger = 0                                // var that indicates to display customAlert
    var wincounts = 0                                           // var that tracks the winning score of user of the phone
    var lostcount = 0                                           // var that tracks the loosing score of user of the phone
    var wincounts_mem = 0                                       // var that stores the last value of wincounts
    var lostcount_mem = 0                                       // var that stores the last value of lostcount
   // var visibleDevices = Array<Device>()
    //var cachedDevices = Array<Device>()
    //var cachedPeripheralNames = Dictionary<String, String>()
    var timer = Timer()                                         // var timer of type Timer, timer interrupt for overhead stuff
    var timer_1sek = Timer()                                    // var timer_1sek of type Timer, timer_1sek interupts every second to assist with countdown
    var timer_10msek = Timer()                                  // var timer_10msek of type Timer, timer_10msek interrupts every 10 mili seconds to update tilt of the phone
    var imMaster = 0                                            // var that contains status if user of the phone is master of BT communication
    var imSlave = 0                                             // var that contains status if user of the phone is slave of BT communication
    var randomnumber = 0                                        // var that contains random number between 0-100 to assist to establish which player is master
    var Seconds_3_countdown = 0                                 // var that assist in the countdown
    //var Seconds_2_countdown = 0
    var Seconds_Random_countdown = 0                            // var that contains the random countdown
    var directionTilt = 0                                       // var that contains value of randomtilt
    var chalenginprogres = 0                                    // var that indicates if challenge is in progress
    var oponentstimeisin = 0                                    // var that indicates if challengers time is in
    var opponentstime = 0.0                                     // var that contains the opponents time
    //var playgame = 0
    var sendMasterScore = 0                                     // var to indicate sending of master score
    var sendSlaveScore = 0                                      // var to indicate sending slave score
    var sendNewchallenge = 0                                    // var to indate sending new challenge
    var circle_Original_X: CGFloat = 0.0                        // var that contains x location of view_SmallCircle
    var circle_Original_Y: CGFloat = 0.0                        // var that contains y location ov view_SmallCircle
    var imMasterFail = 0                                        // var to indicate if master has failed
    var imMasterTimein = 0                                      // var to indicate if masters time is in
    var customAlert: CustomAlertViewVC!                         // var of type CustomAlertViewVC
    var playSound_NotCorrect_playing = 0                        // var to insdicate to play incorrect sound
    var stopwatchcounter = 0.0                                  // var that contains thet value of the stopwatch
    var Message: String?                                        // var of type String that contains Message that is sent to pair device
    var disconnectfrom = 0
    
    /*
     viewDidLoad()
     
     calls viewDidLoad when view is done loading
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        lb_YourName.text = yourName                 // place yourName string in lb_YourName
        lb_OpponentName.text = deviceAttributes     // plase challengers name in lb_OpponentName
        
        image_up.isHidden=true                      // hide up arrow image
        image_down.isHidden=true                    // hide down arrow image
        image_left.isHidden=true                    // hide left arrow image
        image_right.isHidden=true                   // hide up arrow image
        
        btn_NewGame.isHidden = true                 // hide New Game button
        
        view_BigCircle.layer.cornerRadius = view_BigCircle.layer.frame.size.width/2         // set cornerradius of view_BigCircle
        view_MediumCircle.layer.cornerRadius = view_MediumCircle.layer.frame.size.width/2   // set cornerradius of view_MediumCircle
        view_SmallCircle.layer.cornerRadius = view_SmallCircle.layer.frame.size.width/2     // set cornerradius of view_SmallCircle
        view_lb_Countdown.layer.cornerRadius = 15
        
        circle_Original_X = view_SmallCircle.layer.frame.origin.x + (view_SmallCircle.layer.frame.size.width/2) // get the center x location of view_SmallCircle
        circle_Original_Y = view_SmallCircle.layer.frame.origin.y + (view_SmallCircle.layer.frame.size.width/2) // get the center y location of view_SmallCircle
        
        motionManager = CMMotionManager()                                           // init motionManager
        
        if (motionManager.isAccelerometerAvailable){                                // determin if motionManager is available on the device
            motionManager.accelerometerUpdateInterval = 0.01                        // track motion every 10 mili seconds
            motionManager.startAccelerometerUpdates(                                // start motion updates
                to: OperationQueue.current!,
                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
                    self.outputAccelData(acceleration: accelData!.acceleration)
            })
        }
        
        imMaster=0;         // clear imMaster indicator
        imSlave=0;          // clear imSlave indicator
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)    // init centralManager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)             // init peripheralManager
        randomnumber = Int(arc4random_uniform(100))                                     // get random number to assist in deciding who is master
        waitingforchallenger=1
        scheduledTimerWithTimeInterval()                                                // call scheduledTimerWithTimeInterval
    }
    
    /*
     viewDidDisappear(_ animated: Bool)
     
     called when view disapears vrom view
     */
    override func viewDidDisappear(_ animated: Bool)
    {
        
        
    }
    
    /*
     btn_NewGame_Tap(_ sender: Any)
     
     called when btn_NewGame button was pressed
     */
    @IBAction func btn_NewGame_Tap(_ sender: Any) {
        
        wincounts=0                     // clear wincounts
        lostcount=0                     // clear lostcounts
        wincounts_mem=0                 // clear wincounts_mem
        lostcount_mem=0                 // clear lostcount_mem
        btn_NewGame.isHidden = true     // remove btn_NewGame from View
        lb_YourScore.text="0"           // load lb_YourScore with "0"
        lb_OpponentScore.text="0"       // load lb_OpponentScore with "0"
        
        if(imMaster == 1)               // if user of phone is the master of BT communication
        {
            sendSlaveScore = 1
            
            Message="ScoreM:" + String(wincounts)
            centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message

            view_lb_Countdown.isHidden=false
            lb_Countdown.isHidden=false
            lb_Countdown.text = "Get ready..."
        }
        else
        {
            Message="Lets Play"
            centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
            
        }
    }
    
    /*
     btn_Back_Tap(_ sender: Any)
     
     called when btn_Back is tapped
     */
    @IBAction func btn_Back_Tap(_ sender: Any) {
        
        timer.invalidate()          // stop all timer interrupts
        timer_1sek.invalidate()
        timer_10msek.invalidate()
        
        view_lb_Countdown.isHidden=false    // make view_lb_Countdown visable on view
        lb_Countdown.isHidden=false         // make lb_Countdown visable on view
        lb_Countdown.text = "Goodbye"
        
        if(imMaster==1 || imSlave==1)       // if user of phone is the master or slave
        {
            disconnectfrom=1
            Message="disconnect"
            centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
        }
        else
        {
            selectedPeripheral = nil                            // clear selectedPeripheral
            centralManager = nil                                // clear centralManager
            peripheralManager.removeAllServices()               // remove all services from peripheralManager
            self.dismiss(animated: true, completion: nil)       // dismiss view
        }
        imMaster=0;     // clear imMaster indicator
        imSlave=0;      // clear imSlave indicator
    }
    
    /*
     playSound_Correct()
     
     plays the sound if coorect side tilt occured
     */
    func playSound_Correct() {
        // Correct.mp3 file is the correct sound
        guard let url = Bundle.main.url(forResource: "Correct", withExtension: "mp3") else { return } // load Correct.mp3 file path into url var
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)                 // load player with contents of url
            player!.play()                                              // start to play sound
            
        } catch let error {
            print(error.localizedDescription)                           // print when error occured
        }
    }
    
    /*
     playSound_NotCorrect()
     
     plays the sound if incoorect side tilt occured
     */
    func playSound_NotCorrect() {
        // Beep.wav file is the incorrect sound
        guard let url = Bundle.main.url(forResource: "Beep", withExtension: "wav") else { return }// load Beep.wav file path into url var
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)                 // load player with contents of url
            player!.delegate=self                                       // add delegat to player to get notified when sound stop playing
            player!.play()                                              // start to play sound
        } catch let error {
            print(error.localizedDescription)                           // print when error occured
        }
    }
    
    /*
     startGame()
     
     called to setup views and initiat communication to start game
     */
    func startGame()
    {
        view_BigCircle.backgroundColor = UIColor.red    // change view_BigCircle background color to red
        btn_NewGame.isHidden=true                       // hide btn_NewGame from view
        timer.invalidate()                              // clear timers interrupt
        timer_1sek.invalidate()
        timer_10msek.invalidate()
        
        if(imMaster == 1)                               // if Master of BT communication
        {
            sendSlaveScore = 1
            
            Message="ScoreM:" + String(wincounts)
            centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
        }
        else
        {
            view_lb_Countdown.isHidden=false
            lb_Countdown.isHidden=false
            
            switch(winnerorlosser)
            {
                case 0:
                    lb_Countdown.text = "Get ready..."
                    break;
                
                case 1:
                    if(wincounts<10)
                    {
                        lb_Countdown.text = "You Won"
                        indicate_winnerorlosser=2
                    }
                    else
                    {
                        btn_NewGame.isHidden=false
                        lb_Countdown.text = "You Won The Game"
                        winnerorlosser=3
                    }
                    break;
                
                case 2:
                    if(lostcount<10)
                    {
                        lb_Countdown.text = "You Lost"
                        indicate_winnerorlosser=2;
                    }
                    else
                    {
                        btn_NewGame.isHidden=false
                        lb_Countdown.text = "You Lost The Game"
                        winnerorlosser=3
                    }
                    break;
            
                default:
                    lb_Countdown.text = "Get ready..."
                    break;
            }
            
            if(winnerorlosser<3)
            {
                    Seconds_3_countdown = 4
                
                    scheduledTimerWith1SecondTimeInterval()
            }
            chalenginprogres=0
            image_up.isHidden=true
            image_down.isHidden=true
            image_left.isHidden=true
            image_right.isHidden=true
            winnerorlosser=0
        }
    }
    
    /*
     displayAlertview(str :String)
     
     called to present customAlert with string
     */
    func displayAlertview(str :String)
    {
        customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertViewVCID") as! CustomAlertViewVC
        //customAlert.providesPresentationContextTransitionStyle = true
        //customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        //customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.titletext = str
        customAlert.trysome()
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    /*
     outputAccelData(acceleration: CMAcceleration)
     
     called when motion is updated
     
     the main function of this method is to place the small yellow circle in the
     correct place to indicate the level of tilt
     */
    func outputAccelData(acceleration: CMAcceleration){
        let x = acceleration.x
        let y = acceleration.y
        var absolute_x = 0.0
        var absolute_y = 0.0
        
        if(x<0)
        {
            absolute_x = x * (-1.0)
        }
        else
        {
            absolute_x = x
        }
        
        if(y<0)
        {
            absolute_y = y * (-1.0)
        }
        else
        {
            absolute_y = y
        }
        
        let tan_val = atan(absolute_y/absolute_x) * (180.0 / M_PI)
        let sin_val = sin(tan_val * M_PI / 180.0)
        var cos_val = cos(tan_val * M_PI / 180.0)
        
        absolute_y = (sin_val * absolute_y)  * Double(view_BigCircle.layer.frame.size.width/2)
        absolute_x = (cos_val * absolute_x) * Double(view_BigCircle.layer.frame.size.width/2)
        
        if(!absolute_y.isNaN && !absolute_x.isNaN)
        {
            if(x < 0)
            {
                view_SmallCircle.layer.frame.origin.x = circle_Original_X - CGFloat(absolute_x) - (view_SmallCircle.layer.frame.size.width/2)
            }
            else
            {
                view_SmallCircle.layer.frame.origin.x = circle_Original_X + CGFloat(absolute_x) - (view_SmallCircle.layer.frame.size.width/2)
            }
        
            if(y < 0)
            {
                view_SmallCircle.layer.frame.origin.y = circle_Original_Y + CGFloat(absolute_y) - (view_SmallCircle.layer.frame.size.width/2)
            }
            else
            {
                view_SmallCircle.layer.frame.origin.y = circle_Original_Y - CGFloat(absolute_y) - (view_SmallCircle.layer.frame.size.width/2)
            }
        }
        
        let leftright = acceleration.x * 90
        let updown = acceleration.y * 90
        var tiltValue = -1
        if(leftright<(-50))
        {
            tiltValue = 0
        }
        else if(leftright > 50)
        {
            tiltValue = 1
        }
        else
        {
        }
        
        if(updown<(-50))
        {
            tiltValue = 3
        }
        else if(updown > 50)
        {
            tiltValue = 2
        }
        else
        {
        }
        
        if(chalenginprogres==1)
        {
            if(tiltValue != -1)
            {
                chalenginprogres=0
                playSound_NotCorrect()
                if(imMaster==1)
                {
                  imMasterFail=1;
                }
                timer_10msek.invalidate()
                timer_1sek.invalidate()
                lostcount = lostcount + 1
                winnerorlosser = 2
                lb_OpponentScore.text = String(lostcount)
                Message = "oponentsfail"
                centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
            }
        }
        else if(chalenginprogres==2)
        {
            if(directionTilt == tiltValue)
            {
                timer_10msek.invalidate()
                chalenginprogres=3
                view_lb_Countdown.isHidden=false
                lb_Countdown.isHidden=false
                lb_Countdown.text = String(format: "%.2f",stopwatchcounter)
                Message = "oponentstime:" + String(format: "%.2f",stopwatchcounter)
                centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
                playSound_Correct()
                view_BigCircle.backgroundColor = UIColor.green    // change view_BigCircle background color to green

                if(oponentstimeisin == 1)
                {
                    if(opponentstime > stopwatchcounter)
                    {
                        wincounts = wincounts + 1
                        winnerorlosser = 1
                        lb_YourScore.text = String(wincounts)
                    }
                    else
                    {
                        lostcount = lostcount + 1
                        winnerorlosser = 2
                        lb_OpponentScore.text = String(lostcount)
                    }
                    
                    if(imMaster==1)
                    {
                        imMasterTimein=1;
                    }
                }
            }
            else
            {
                if(tiltValue != -1  && playSound_NotCorrect_playing==0)
                {
                    playSound_NotCorrect_playing=1
                    playSound_NotCorrect()
                }
            }
        }
    }
    
    /*
     scheduledTimerWith1SecondTimeInterval()
     
     called to schedule onTick_1second timer interrupt
     */
    func scheduledTimerWith1SecondTimeInterval(){
        timer_1sek = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onTick_1second), userInfo: nil, repeats: true)
    }
    
    /*
     onTick_1second()
     
     called when onTick_1second iterrpt occure
     */
    @objc func onTick_1second()
    {
        if(indicate_winnerorlosser>0)
        {
            indicate_winnerorlosser = indicate_winnerorlosser - 1
        }
        else
        {
            if(Seconds_3_countdown>0)
            {
                Seconds_3_countdown = Seconds_3_countdown - 1
                lb_Countdown.text = String(Seconds_3_countdown)
            }
            else
            {
                oponentstimeisin=0
                opponentstime=0.0
                stopwatchcounter=0
                lb_Countdown.isHidden=true
                view_lb_Countdown.isHidden=true
                if(Seconds_Random_countdown>0)
                {
                    chalenginprogres=1
                    Seconds_Random_countdown = Seconds_Random_countdown - 1
                }
                else
                {
                    switch(directionTilt)
                    {
                        case 0:
                            image_left.isHidden=false
                            break;
                        case 1:
                            image_right.isHidden=false
                            break;
                        case 2:
                            image_up.isHidden=false
                            break;
                        case 3:
                            image_down.isHidden=false
                            break;
                        default:
                            break;
                    }
                    scheduledTimerWith10miliSecondTimeInterval()
                    chalenginprogres=2
                    timer_1sek.invalidate()
                }
            }
        }
    }
    
    /*
     scheduledTimerWith10miliSecondTimeInterval()
     
     called to schedule onTick_10msecond timer interrupt
     */
    func scheduledTimerWith10miliSecondTimeInterval(){
        timer_10msek = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.onTick_10msecond), userInfo: nil, repeats: true)
    }
    
    
    /*
     onTick_10msecond()
     
     called when onTick_10msecond iterrpt occure
     */
    @objc func onTick_10msecond(){
        stopwatchcounter = stopwatchcounter + 0.01  // increment stopwatchcounter by 0.1
        if(oponentstimeisin==1)
        {
            if((opponentstime + 2.0) < stopwatchcounter)
            {
                if(imMaster==1)
                {
                    imMasterFail=1;
                }
                lostcount = lostcount + 1
                winnerorlosser = 2
                lb_OpponentScore.text = String(lostcount)
                timer_10msek.invalidate()
                Message = "oponentsfail"
                centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
            }
        }
    }

    /*
     scheduledTimerWithTimeInterval()
     
     called to schedule IamMasterTimer timer interrupt
     */
    func scheduledTimerWithTimeInterval(){
       timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.IamMasterTimer), userInfo: nil, repeats: true)
    }
    
    
    /*
     IamMasterTimer()
     
     called when IamMasterTimer iterrpt occure
     */
    @objc func IamMasterTimer(){
        if(waitingforchallenger==1)
        {
            waitingforchallenger = waitingforchallenger + 1
            displayAlertview(str :"Waiting for challenger...")
        }
        if(( imMaster==0 ) && ( imSlave==0 ) )
        {
            Message="I am Master " + String(randomnumber)
            if(  selectedPeripheral?.name != nil)
            {
                centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
            }
        }
        else if(imMaster==1 && imSlave==1)
        {
            imMaster=0;
            imSlave=0;
        }
        else
        {
            timer.invalidate()
        }
    }
    

    func updateAdvertisingData() {
        
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let userData = UserData()
        let advertisementData = String(format: "%@", userData.name)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[Constants.SERVICE_UUID], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    func initService() {
        
        let serialService = CBMutableService(type: Constants.SERVICE_UUID, primary: true)
        let rx = CBMutableCharacteristic(type: Constants.RX_UUID, properties: Constants.RX_PROPERTIES, value: nil, permissions: Constants.RX_PERMISSIONS)
        serialService.characteristics = [rx]
        
        peripheralManager.add(serialService)
    }
    
}

extension ControlVC : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn){
            
            self.centralManager?.scanForPeripherals(withServices: [Constants.SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if (peripheral.identifier == deviceUUID) {
            
            selectedPeripheral = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
}

extension ControlVC : CBPeripheralDelegate {
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        
        for characteristic in service.characteristics! {
            
            let characteristic = characteristic as CBCharacteristic
            if (characteristic.uuid.isEqual(Constants.RX_UUID)) {
                
                    if let messageText = Message {
                        let data = messageText.data(using: .utf8)
                    peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        Message="";
                        if(imMasterFail==1 || imMasterTimein==1)
                        {
                         startGame()
                            imMasterFail=0
                            imMasterTimein=0
                        }
                        if(disconnectfrom==1)
                        {
                            disconnectfrom=0
                            centralManager?.cancelPeripheralConnection(selectedPeripheral!)
                            selectedPeripheral = nil
                            centralManager = nil
                            peripheralManager.removeAllServices()
                            self.dismiss(animated: true, completion: nil)
                        }
                        if(sendNewchallenge == 1)
                        {
                            sendNewchallenge = 0
                            directionTilt = Int(arc4random_uniform(4))
                            Seconds_Random_countdown = Int(arc4random_uniform(6)) + 2
                            Message="dir:" + String(directionTilt) + ",time:" + String(Seconds_Random_countdown)
                            centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
                            
                            view_lb_Countdown.isHidden=false
                            lb_Countdown.isHidden=false
                            btn_NewGame.isHidden = true
                            switch(winnerorlosser)
                            {
                                case 0:
                                    lb_Countdown.text = "Get ready..."
                                    break;
                                
                                case 1:
                                    if(wincounts<10)
                                    {
                                        lb_Countdown.text = "You Won"
                                        indicate_winnerorlosser=2
                                    }
                                    else
                                    {
                                        btn_NewGame.isHidden=false
                                        lb_Countdown.text = "You Won The Game"
                                        winnerorlosser=3
                                    }
                                    break;
                            
                                case 2:
                                    if(lostcount<10)
                                    {
                                        lb_Countdown.text = "You Lost"
                                        indicate_winnerorlosser=2;
                                    }
                                    else
                                    {
                                        btn_NewGame.isHidden=false
                                        lb_Countdown.text = "You Lost The Game"
                                        winnerorlosser=3
                                    }
                                    break;
                                
                                default:
                                    lb_Countdown.text = "Get ready..."
                                    break;
                            }
                           
                            if(winnerorlosser<3)
                            {
                                Seconds_3_countdown = 4
                                
                                scheduledTimerWith1SecondTimeInterval()
                            }
                            chalenginprogres=0
                            image_up.isHidden=true
                            image_down.isHidden=true
                            image_left.isHidden=true
                            image_right.isHidden=true
                            winnerorlosser=0
                        }
                        if(sendSlaveScore == 1)
                        {
                            sendSlaveScore = 0
                            sendNewchallenge = 1
                            Message="ScoreS:" + String(lostcount)
                            centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
                        }
                        
                        var i = 0
                        if(i==0)
                        {
                            i=1
                        }
                }
            }
        }
    }
}

extension ControlVC : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            
            initService()
            updateAdvertisingData()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            if let value = request.value {
                
                let messageText = String(data: value, encoding: String.Encoding.utf8) as String!
                
                if(messageText!.contains("I am Master"))
                {
                    let c = messageText!.characters
                    
                    let range = c.index(c.startIndex, offsetBy: 12)..<c.endIndex
                    let substring = messageText![range]
                    if(randomnumber <   (substring as NSString).integerValue)
                    {
                        if(customAlert != nil)
                        {
                            customAlert.removeView()
                        }
                        imSlave=1;
                        Message="I am Slave"
                        centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
                    }
                    else if(randomnumber ==  (substring as NSString).integerValue)
                    {
                        randomnumber = Int(arc4random_uniform(100))
                    }
                }
                else if(messageText!.contains("I am Slave"))
                {
                    if(customAlert != nil)
                    {
                        customAlert.removeView()
                    }
                    imMaster=1;
                    startGame()
                }
                else if(messageText!.contains("disconnect"))
                {
                    if(customAlert != nil)
                    {
                        customAlert.removeView()
                    }
                    timer.invalidate()
                    timer_1sek.invalidate()
                    timer_10msek.invalidate()
                    imMaster=0;
                    imSlave=0;
                    view_lb_Countdown.isHidden=false
                    lb_Countdown.isHidden=false
                    lb_Countdown.text = "Goodbye"
                    centralManager?.cancelPeripheralConnection(selectedPeripheral!)
                    selectedPeripheral = nil
                    centralManager = nil
                    peripheralManager.removeAllServices()
                    self.dismiss(animated: true, completion: nil)
                }
                else if(messageText!.contains("dir:") && messageText!.contains("time:"))
                {
                    if(customAlert != nil)
                    {
                        customAlert.removeView()
                    }
                    let c = messageText!.characters
                    
                    let start = c.index(c.startIndex, offsetBy: 4)
                    let end = c.index(c.endIndex, offsetBy: -7)
                    var range = start..<end
                    
                    var mySubstring = messageText![range]
                    
                    directionTilt = (mySubstring as NSString).integerValue
                    range = c.index(c.startIndex, offsetBy: 11)..<c.endIndex
                    mySubstring = messageText![range]
                    Seconds_Random_countdown = (mySubstring as NSString).integerValue
                    
                    startGame()
                }
                else if(messageText!.contains("ScoreM:"))
                {
                    if(customAlert != nil)
                    {
                        customAlert.removeView()
                    }
                    let c = messageText!.characters
                    
                    let start = c.index(c.startIndex, offsetBy: 7)
                    let end = c.endIndex
                    var range = start..<end
                    
                    var mySubstring = messageText![range]
                    
                    lostcount = (mySubstring as NSString).integerValue
                    lb_OpponentScore.text = String(lostcount)
                    if(lostcount_mem<lostcount)
                    {
                        winnerorlosser = 2
                    }
                    lostcount_mem=lostcount
                }
                else if(messageText!.contains("ScoreS:"))
                {
                    if(customAlert != nil)
                    {
                        customAlert.removeView()
                    }
                    let c = messageText!.characters
                    
                    let start = c.index(c.startIndex, offsetBy: 7)
                    let end = c.endIndex
                    var range = start..<end
                    
                    var mySubstring = messageText![range]
                    
                    wincounts = (mySubstring as NSString).integerValue
                    
                    lb_YourScore.text = String(wincounts)
                    if(wincounts_mem<wincounts)
                    {
                        winnerorlosser = 1
                    }
                    wincounts_mem=wincounts
                }
                else if(messageText!.contains("oponentstime:"))// && imMaster==0 && imSlave==0)
                {
                    oponentstimeisin=1;
                    let c = messageText!.characters
                    
                    let range = c.index(c.startIndex, offsetBy: 13)..<c.endIndex
                    let substring = messageText![range]
                    opponentstime = (substring as NSString).doubleValue
                    
                    if(chalenginprogres == 3)
                    {
                        if(opponentstime > stopwatchcounter)
                        {
                            wincounts = wincounts + 1
                            winnerorlosser = 1
                            lb_YourScore.text = String(wincounts)
                        }
                        else
                        {
                            winnerorlosser = 2
                            lostcount = lostcount + 1
                            lb_OpponentScore.text = String(lostcount)
                        }
                        startGame()
                    }
                }
                else if(messageText!.contains("oponentsfail"))
                {
                    timer_10msek.invalidate()
                    timer_1sek.invalidate()
                    wincounts = wincounts + 1
                    winnerorlosser = 1
                    lb_YourScore.text = String(wincounts)
                    startGame()
                }
                else if(messageText!.contains("Lets Play"))
                {
                    wincounts=0;
                    lostcount=0;
                    wincounts_mem=0;
                    lostcount_mem=0;
                    winnerorlosser=0;
                    lb_YourScore.text = "0"
                    lb_OpponentScore.text = "0"
                    btn_NewGame.isHidden = true
                    startGame()
                }
                else
                {
                }
            }
            self.peripheralManager.respond(to: request, withResult: .success)
        }
    }
}

extension ControlVC: CustomAlertViewDelegate {
    
    func okButtonTapped(selectedOption: String, textFieldValue: String) {
        print("okButtonTapped with \(selectedOption) option selected")
        print("TextField has value: \(textFieldValue)")
    }
    
    func cancelButtonTapped() {
        print("cancelButtonTapped")
        customAlert.removeView()
        timer.invalidate()
        timer_1sek.invalidate()
        timer_10msek.invalidate()

        view_lb_Countdown.isHidden=false
        lb_Countdown.isHidden=false
        lb_Countdown.text = "Goodbye"
        
        if(imMaster==1 || imSlave==1)
        {
            disconnectfrom=1
            Message="disconnect"
            centralManager?.connect(selectedPeripheral!, options: nil)  // initiat communication to send contents of Message
        }
        else
        {
            selectedPeripheral = nil
            centralManager = nil
            peripheralManager.removeAllServices()
            self.dismiss(animated: true, completion: nil)
        }
        imMaster=0;
        imSlave=0;
    }
}

extension ControlVC: AVAudioPlayerDelegate {
    
     func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                              successfully flag: Bool)
    {
        playSound_NotCorrect_playing=0
    }
}
