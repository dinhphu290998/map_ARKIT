//
//  ViewController.swift
//  Ai-alearn
//
//  Created by NDPhu on 8/8/19.
//  Copyright © 2019 NDPhu. All rights reserved.
//

import AVFoundation
import UIKit
import ARKit
import ARCL
import SceneKit
import CoreLocation
import SVProgressHUD
import Alamofire

class ViewController: UIViewController ,ARSCNViewDelegate{
    var memoList : [Memo] = []
    let locationManager: CLLocationManager = CLLocationManager()
    var distance = 20.0
    var categorys = [Int]()
    var sceneLocationView = SceneLocationView()
    var listLocationNode = [LocationAnnotationNode]()
    var listCategory = [Category]()
    var categoryAll = Category(id: 99, name: "Selected None", select: 1)
    var checkSelected = 0
    @IBOutlet weak var viewEnable: UIView!
    @IBOutlet weak var checkAllCollection: UICollectionView!
    @IBOutlet weak var km: UILabel!
    @IBOutlet weak var viewAR: UIView!
    @IBOutlet weak var settingBt: UIButton!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var nameWorker: UILabel!
    @IBOutlet weak var nameCategory: UILabel!
    @IBOutlet weak var rangerLb: UILabel!
    @IBOutlet weak var viewSlider: UIStackView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var distanceLb: UILabel!
    @IBOutlet weak var backBt: UIButton!
    @IBOutlet weak var showDt: UIButton!
    override func viewDidLoad() {
        viewAR.addSubview(sceneLocationView)
        sceneLocationView.locationNodeTouchDelegate = self
        let cellNib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        self.categoryCollectionView.register(cellNib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.checkAllCollection.register(cellNib, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        viewShadow.layer.cornerRadius = 10
        viewDetail.layer.cornerRadius = 10
        SVProgressHUD.show(withStatus: "Loading")
        DispatchQueue.global().async {
            self.getDataMemo()
            self.getCategory()
        }
        self.setupLocationDevice()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = viewAR.bounds
    }
    func addPoint(lat: Double, lon: Double, name: String, img: String, height: CGFloat, width: CGFloat){
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let location = CLLocation(coordinate: coordinate, altitude: 0)
        let imgView = UIImageView(image: UIImage.init(named: img))
        imgView.frame.size.height = height
        imgView.frame.size.width = width
        let annotationNode = LocationAnnotationNode(location: location, view: imgView)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        annotationNode.annotationNode.name = name
        listLocationNode.append(annotationNode)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDetail.isHidden = true
        viewShadow.isHidden = true
        hideButton.isHidden = true
        showDt.isHidden = true
        settingBt.isHidden = false
        sceneLocationView.run()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
   
    func getDataMemo(){
        guard let domain = UserDefaults.standard.value(forKey: "domain") else { return }
        let urlString = "\(domain)/api/v1/memo/list?username=vtest1"
        Alamofire.request(URL.init(string: urlString)!).responseJSON { (response) in
            if let JSON = response.result.value as? [String: Any]{
                guard let data = JSON["data"] as? [[String: Any]] else {return}
                for item in data {
                    let category_id = item["category_id"] as? Int ?? 0
                    var category_name = item["category_name"] as? String ?? ""
                    if category_name == "" {
                        category_name = "その他"
                    }
                    let user_id = item["user_id"] as? Int ?? 0
                    let user_name = item["user_name"] as? String ?? ""
                    let kml_id = item["kml_id"] as? Int ?? 0
                    let memo_at = item["memo_at"] as? Double ?? 0.0
                    let memo_at_str = item["memo_at_str"] as? String ?? ""
                    let content = item["content"] as? String ?? ""
                    let collection_time = item["collection_time"] as? String ?? ""
                    guard let lat = item["lat"] as? String else {return}
                    guard let lng = item["lng"] as? String else {return}
                    let memo = Memo.init(category_id: category_id, category_name: category_name, collection_time: collection_time, content: content, kml_id: kml_id, lat: lat, lng: lng, memo_at: memo_at, memo_at_str: memo_at_str, user_id: user_id, user_name: user_name)
                    self.memoList.append(memo)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss(withDelay: 4)
                    }
                }
            }
        }
    }
    func getCategory(){
        guard let domain = UserDefaults.standard.value(forKey: "domain") else { return }
        let urlString = "\(domain)/api/v1/category/list"
        Alamofire.request(URL.init(string: urlString)!).responseJSON { (response) in
            if let JSON = response.result.value as? [String: Any]{
                guard let data = JSON["data"] as? [[String: Any]] else {return}
                let cateOther = Category.init(id: 0, name: "その他", select: 1)
                for item in data {
                    let id = item["id"] as? Int ?? 100
                    let name = item["name"] as? String ?? "その他"
                    let category = Category.init(id: id, name: name, select: 1)
                    self.listCategory.append(category)
                    self.categorys.append(id)
                }
                self.listCategory.append(cateOther)
                self.categorys.append(0)
                self.checkSelected = self.listCategory.count
                DispatchQueue.main.async {
                    self.categoryCollectionView.reloadData()
                }
            }
        }
    }
  
    @IBAction func hide(_ sender: UIButton) {
        viewDetail.isHidden = true
        viewShadow.isHidden = true
        hideButton.isHidden = true
        showDt.isHidden = true
        settingBt.isHidden = false
        settingBt.isSelected = false
    }
    
    @IBAction func slider(_ sender: UISlider) {
        DispatchQueue.main.async {
            if Int(sender.value) < 1 || Int(sender.value) == 1{
                sender.value = 1
                self.distanceLb.text = "\(1)"
                self.distance = 1.0
            }else if Int(sender.value) > 1 && Int(sender.value) < 2 || Int(sender.value) == 2{
                sender.value = 2
                self.distanceLb.text = "\(2)"
                self.distance = 2.0
            }else if Int(sender.value) > 2 && Int(sender.value) < 3 || Int(sender.value) == 3{
                sender.value = 3
                self.distanceLb.text = "\(3)"
                self.distance = 3.0
            }else if Int(sender.value) > 3 && Int(sender.value) < 4 || Int(sender.value) == 4{
                sender.value = 4
                self.distanceLb.text = "\(5)"
                self.distance = 5.0
            }else if Int(sender.value) > 4 && Int(sender.value) < 5 || Int(sender.value) == 5{
                sender.value = 5
                self.distanceLb.text = "\(10)"
                self.distance = 10
            }else if Int(sender.value) > 5 && Int(sender.value) < 6 || Int(sender.value) == 6{
                sender.value = 6
                self.distanceLb.text = "\(20)"
                self.distance = 20
            }
        }
    }
    @IBAction func settings(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            rangerLb.isHidden = false
            viewSlider.isHidden = false
            checkAllCollection.isHidden = false
            categoryCollectionView.isHidden = false
            backBt.isHidden = true
            km.isHidden = false
        }else{
            rangerLb.isHidden = true
            viewSlider.isHidden = true
            checkAllCollection.isHidden = true
            categoryCollectionView.isHidden = true
            backBt.isHidden = false
            km.isHidden = true
        }
    }
    
    @IBAction func backBt(_ sender: UIButton) {
        // create the alert
        let alert = UIAlertController(title: "ログアウトしてログイン画面に戻りますか？", message: "", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
            UserDefaults.standard.set(false, forKey: "check")
            let application = UIApplication.shared.delegate as! AppDelegate
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "CodeCompanyController")
            let navigationController = UINavigationController(rootViewController: rootViewController)
            navigationController.isNavigationBarHidden = true
            application.window?.rootViewController = navigationController
        }))
        alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: LNTouchDelegate {
    func locationNodeTouched(node: AnnotationNode) {
        viewDetail.isHidden = false
        viewShadow.isHidden = false
        hideButton.isHidden = false
        showDt.isHidden = false
        settingBt.isHidden = true
        rangerLb.isHidden = true
        viewSlider.isHidden = true
        checkAllCollection.isHidden = true
        categoryCollectionView.isHidden = true
        backBt.isHidden = false
        km.isHidden = true
        guard let index = Int(node.name!) else { return }
        let dataJs = memoList[index]
        self.nameCategory.text = dataJs.category_name
        self.nameWorker.text = dataJs.user_name
        self.date.text = dataJs.collection_time
        self.memo.text = dataJs.content
    }
}

extension ViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == checkAllCollection{
            return 1
        }else{
            return listCategory.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == checkAllCollection{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.layer.cornerRadius = 5
            cell.viewSelected.backgroundColor = .clear
            if self.checkSelected == self.listCategory.count{
                cell.nameCategory.textColor = UIColor.white
                cell.nameCategory.text = "Selected None"
            }else{
                cell.nameCategory.textColor = UIColor(red: 38.25/255, green: 173.4/255, blue: 96.6/255, alpha: 1)
                cell.nameCategory.text = "Selected All"
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            let catego = listCategory[indexPath.item]
            cell.nameCategory.text = catego.name
            cell.layer.cornerRadius = 5
            if listCategory[indexPath.item].select == 1{
                cell.viewSelected.backgroundColor = UIColor(red: 38.25/255, green: 173.4/255, blue: 96.6/255, alpha: 1)
            }else{
                cell.viewSelected.backgroundColor = .clear
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == checkAllCollection{
            categoryAll.select = -categoryAll.select!
            if categoryAll.select == 1{
                self.checkSelected = self.listCategory.count
                for cate in listCategory{
                    cate.select = 1
                    self.categorys.append(cate.id!)
                    self.categoryCollectionView.reloadData()
                }
                self.checkAllCollection.reloadData()
            }else{
                self.checkSelected = 0
                for cate in listCategory{
                    cate.select = -1
                    self.categoryCollectionView.reloadData()
                }
                self.categorys = []
                
                self.checkAllCollection.reloadData()
            }
        }else{
            listCategory[indexPath.item].select = -listCategory[indexPath.item].select!
            if listCategory[indexPath.item].select == -1{
                self.checkSelected = self.checkSelected - 1
                for i in 0...self.categorys.count-1{
                    if self.categorys[i] == listCategory[indexPath.row].id {
                        categorys[i] = -1
                    }
                }
                categoryAll.select = -1
                categoryCollectionView.reloadData()
                self.checkAllCollection.reloadData()
            }else{
                self.checkSelected = self.checkSelected + 1
                self.categorys.append(listCategory[indexPath.row].id!)
                if self.categorys.count == self.listCategory.count{
                    categoryAll.select = 1
                }
                self.checkAllCollection.reloadData()
                categoryCollectionView.reloadData()
            }
        }
        viewEnable.isHidden = false
        SVProgressHUD.show(withStatus: "loading")
        SVProgressHUD.dismiss(withDelay: 4) {
            self.viewEnable.isHidden = true
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == checkAllCollection{
            let width = categoryAll.name?.count ?? 5
            return CGSize.init(width: width * 10, height: 50)
        }else{
            let category = listCategory[indexPath.item]
            let width = category.name?.count ?? 5
            return CGSize.init(width: width * 20, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
extension ViewController: CLLocationManagerDelegate{
    func setupLocationDevice() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateLocationDevice), userInfo: nil, repeats: true)
        }
    }
    @objc func updateLocationDevice (){
        Timer.scheduledTimer(timeInterval: 4.75, target: self, selector: #selector(self.removeParent), userInfo: nil, repeats: false)
        if self.locationManager.location != nil {
            for i in 0...memoList.count-1{
                let point = memoList[i]
                guard let lat = Double(point.lat!) else {return}
                guard let lng = Double(point.lng!) else {return}
                let dist = getDistanceFromPointToDevice(latDevice: self.locationManager.location!.coordinate.latitude, lonDevice: self.locationManager.location!.coordinate.longitude, latPoint: lat , lonPoint: lng)
                guard let cateId = point.category_id else { return }
                if dist < self.distance || dist == self.distance{
                    print(memoList[i])
                    if self.categorys.count != 0 {
                        for i in 0...categorys.count-1{
                            if cateId == categorys[i] {
                                if dist < 1 || dist == 1{
                                    addPoint(lat: lat, lon: lng, name: "\(i)", img: point.imgString , height: 120, width: 80)
                                }else if dist < 3 && dist > 1 || dist == 3{
                                    addPoint(lat: lat , lon: lng, name: "\(i)", img: point.imgString, height: 100, width: 70)
                                }else if dist < 10 && dist > 3 || dist == 10{
                                    addPoint(lat: lat , lon: lng , name: "\(i)", img: point.imgString, height: 70, width: 55)
                                }else if dist > 10 {
                                    addPoint(lat: lat, lon: lng , name: "\(i)", img: point.imgString, height: 60, width: 40)
                                }
                            }
                        }
                    }else{
                        for node in listLocationNode{
                            node.annotationNode.removeFromParentNode()
                            sceneLocationView.removeAllNodes()
                            sceneLocationView.scene.removeAllParticleSystems()
                        }
                    }
                }
            }
        }
    }
    @objc func removeParent() {
        for node in listLocationNode{
            node.annotationNode.removeFromParentNode()
            sceneLocationView.removeAllNodes()
            sceneLocationView.scene.removeAllParticleSystems()
        }
    }
    //Distance From Point To Device
    func getDistanceFromPointToDevice(latDevice: Double,lonDevice: Double,latPoint: Double,lonPoint: Double) -> Double{
        let pixelLocal = self.convLatLon2Pixel(lat: latDevice, lon: lonDevice, zoom: 0)
        let pixelPoint = self.convLatLon2Pixel(lat: latPoint, lon: lonPoint, zoom: 0)
        let ax = Double(pixelPoint.x!) - Double(pixelLocal.x!)
        let az = Double(pixelPoint.z!) - Double(pixelLocal.z!)
        let a = (pow(ax, 2) + pow(az, 2)) * 10000
        return a
    }
    //convert lat lon to Oxy
    func convLatLon2Pixel(lat: Double,lon: Double,zoom: Double) -> Pixel{
        let n = pow(2,zoom + 7)
        let L = 85.05112878
        let x = ((lon / 180 ) + 1) * n
        let z = (n  / .pi) * ((-tanhInv(a: sin(lat * .pi / 180))) + tanhInv(a: sin(L * .pi / 180)))
        let pixel = Pixel.init(x: x, z: z)
        return pixel
    }
    func tanhInv(a: Double) -> Double{
        return log((1 + a) / (1 - a)) / 2
    }
}
