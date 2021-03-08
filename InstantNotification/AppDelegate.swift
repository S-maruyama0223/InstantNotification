//
//  AppDelegate.swift
//  InstantNotification
//
//  Created by Shotaro Maruyama on 2021/02/08.
//  
//

import UIKit
import NCMB
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let APPLICATION_KEY = "9641fd0e538574f60dd3d22ff3abfeb52492ecf25f65e79e3d663813d5f478bc"
    let CLIENT_KEY = "1432ac554739af77ac5e463c10493f94bb4fb2e141a0bb608b3dd9fad4d4b5f3"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if((error) != nil) {
                print(" エラー")
                return
            }
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //端末情報を扱うNCMBInstallationのインスタンスを作成
        let installation : NCMBInstallation = NCMBInstallation.currentInstallation

        //Device Tokenを設定
        installation.setDeviceTokenFromData(data: deviceToken)

        //端末情報をデータストアに登録
        installation.saveInBackground(callback: { result in
            switch result {
            case .success:
                //端末情報の登録が成功した場合の処理
                print("保存に成功しました")
            case let .failure(error):
                //端末情報の登録が失敗した場合の処理
                let errorCode = (error as! NCMBApiError).errorCode;
                if (errorCode == NCMBApiErrorCode.duplication) {
                    //失敗した原因がdeviceTokenの重複だった場合
                    self.updateExistInstallation(installation: installation)
                } else if (errorCode == NCMBApiErrorCode.noDataAvailable) {
                    //失敗した原因がdeviceTokenの該当データが無い場合
                    self.reRegistInstallation(installation: installation)
                } else {
                    //deviceTokenの該当データが無いエラー以外が返ってきた場合
                }
                return
            }
        })
    }
    //deviceTokenの重複で端末情報の登録に失敗した場合に上書き処理を行う
    func updateExistInstallation(installation: NCMBInstallation) -> Void {
        var installationQuery : NCMBQuery<NCMBInstallation> = NCMBInstallation.query
        installationQuery.where(field: "deviceToken", equalTo: installation.deviceToken!)
        installationQuery.findInBackground(callback: {results in
            switch results {
            case let .success(data):
                //上書き保存する
                let searchDevice:NCMBInstallation = data.first!
                installation.objectId = searchDevice.objectId
                installation.saveInBackground(callback: { result in
                    switch result {
                    case .success:
                        //端末情報更新に成功したときの処理
                        break
                    case .failure:
                        //端末情報更新に失敗したときの処理
                        break
                    }
                })
            case .failure:
                //端末情報検索に失敗した場合の処理
                break
            }
        })
    }

    //mobile backend上に該当データがない場合に新規作成処理を行う
    func reRegistInstallation(installation: NCMBInstallation) -> Void {
        //objectIdのみ削除し、installationが再生成されるようにする
        installation.objectId = nil
        //端末情報をデータストアに登録
        installation.saveInBackground(callback: { result in
            switch result {
            case .success:
                //端末情報の登録が成功した場合の処理
                break
            case let .failure(error):
                //端末情報の登録が失敗した場合の処理
                break
            }
        })
    }

}
