//
//  AWSIdentityManager.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/28/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//
import AWSCore

func elmo(result: AnyObject?, error: NSError)-> Void {}
public class AWSIdentityManager : NSObject, AWSIdentityProviderManager  {
    static var _defaultIdentityManager: AWSIdentityManager? = nil
    public static let DidSignInNotification: String = "com.amazonaws.AWSIdentityManager.AWSIdentityManagerDidSignInNotification";
    public static let DidSignOutNotification: String = "com.amazonaws.AWSIdentityManager.AWSIdentityManagerDidSignOutNotification";
    typealias AWSIdentityManagerCompletionBlock = (String, NSError) -> Void
    /**
     * Amazon Cognito Credentials Provider. This is the credential provider used by the Identity Manager.
     *
     * @return the cognito credentials provider
     */
    public var credentialsProvider: AWSCognitoCredentialsProvider? = nil

    public var completionHandler: (AnyObject?, NSError) -> Void = elmo
    var currentSignInProvider: AWSSignInProvider? = nil
    
    /**
     The name of the identity provider. e.g. graph.facebook.com.
     */
    var identityProviderName: String = "None"
    /**
     Each entry in logins represents a single login with an identity provider. The key is the domain of the login provider (e.g. 'graph.facebook.com') and the value is the OAuth/OpenId Connect token that results from an authentication with that login provider.
     */
    public func logins() -> AWSTask<NSDictionary> {
        if let provider = self.currentSignInProvider {
            let handle = provider.token().continueWith(block: { (task) -> Any? in
                if let token = task.result as String? {
                    let result:NSDictionary = [provider.identityProviderName : token]
                    return AWSTask(result: result)
                }
                return nil
            })
            if let handle = handle as? AWSTask<NSDictionary> {
                return handle
            } else {
                return AWSTask(result: nil)
            }
        } else {
            return AWSTask(result: nil)
        }
    }
    /**
     Each entry in logins represents a single login with an identity provider. The key is the domain of the login provider (e.g. 'graph.facebook.com') and the value is the OAuth/OpenId Connect token that results from an authentication with that login provider.
     */
    
    static let AWSInfoIdentityManager: String = "IdentityManager";
    static let AWSInfoRoot: String = "AWS";
    static let AWSInfoMobileHub: String = "MobileHub";
    static let AWSInfoProjectClientId: String = "ProjectClientId";
    /**
     Returns the token associated with this provider. If the token is cached and invalid, should refresh and return the valid token.
     */
   // var token: AWSTask<NSString>

    init(serviceInfo: AWSServiceInfo?) {
        super.init()
        AWSLogger.default().logLevel = AWSLogLevel.verbose
        if let serviceInfo = serviceInfo {
            let provider = serviceInfo.cognitoCredentialsProvider
            self.credentialsProvider = provider
            provider.setIdentityProviderManagerOnce(self)
            // Init the Project Template ID
            var projectTemplateID: String = "MobileHub HelperFramework"
            if let top = AWSInfo.default().rootInfoDictionary[AWSIdentityManager.AWSInfoMobileHub] as? [String : String ] {
                if let id = top[AWSIdentityManager.AWSInfoProjectClientId] {
                    projectTemplateID = id
                }
            }
            AWSServiceConfiguration.addGlobalUserAgentProductToken(projectTemplateID)
        } else {
            print("AWSIdentityManager failed to initialize")
        }
    }

    
    /**
     * URL for the user's image, if user is signed-in with a third party identity provider,
     * like Facebook or Google.
     * @return url of image file, if user is signed-in
     */
    public var imageURL: NSURL? {
        get {
            if let provider = self.currentSignInProvider {
                return provider.imageURL
            }
            return nil
        }
    }
    
    /**
     * User name acquired from third party identity provider, such as Facebook or Google.
     * @return user name, if user is signed-in
     */
    public var userName: String? {
        get {
            if let provider = self.currentSignInProvider {
                return provider.userName
            }
            return nil
        }
    }
    public func wipeAll() -> Void {
        if let provider = self.credentialsProvider {
            provider.clearKeychain()
        }
    }
    
    
    /**
     * Amazon Cognito User Identity ID. This uniquely identifies the user, regardless of
     * whether or not the user is signed-in, if User Sign-in is enabled in the project.
     * @return unique user identifier
     */
    public var identityId: String? {
        get {
            if let credentialsProvider = self.credentialsProvider { return credentialsProvider.identityId}
            return nil
        }
    }
    
    public var isLoggedIn: Bool {
        get {
            if let provider = self.currentSignInProvider {
                return provider.loggedIn
            }
            return false
        }
    }

    
    /**
     Returns the Identity Manager singleton instance configured using the information provided in `Info.plist` file.
     
     *Swift*
     
     let identityManager = AWSIdentityManager.defaultIdentityManager()
     
     *Objective-C*
     
     AWSIdentityManager *identityManager = [AWSIdentityManager defaultIdentityManager];
     */
    public class func defaultIdentityManager() -> AWSIdentityManager? {
        if AWSIdentityManager._defaultIdentityManager != nil { return AWSIdentityManager._defaultIdentityManager }
        let serviceInfo: AWSServiceInfo? = AWSInfo().defaultServiceInfo(AWSInfoIdentityManager)
        if serviceInfo == nil {
            print("AWS Fatal Error. he AWS service configuration is nil, You need to configure Info.plit before this method")
        } else {
            AWSIdentityManager._defaultIdentityManager = AWSIdentityManager(serviceInfo: serviceInfo)
            print("Created DefaultIdentityManager")
        }
        return AWSIdentityManager._defaultIdentityManager
    }
    
    /**
     * Signs the user out of whatever third party identity provider they used to sign in.
     * @param completionHandler used to callback application with async operation results
     */
    public func logoutWithCompletionHandler(completionHandler: @escaping (AnyObject?, Error?) -> Void) {
        if let provider = self.currentSignInProvider {
            if provider.loggedIn {
                provider.logout()
            }
        }
        self.wipeAll()
        self.currentSignInProvider = nil
        if let credentials = self.credentialsProvider {
            credentials.getIdentityId().continue({ (task: AWSTask<NSString>) -> Any? in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AWSIdentityManager.DidSignOutNotification), object: AWSIdentityManager.defaultIdentityManager(), userInfo: nil)
                    if let exception = task.exception {
                        print("AWS Identity Manager Fatal Exception in logout")
                        print(exception)
                        kill(getpid(), SIGKILL)
                    }
                    completionHandler(task.result, task.error)
                }
            })
        }
    }
    
    /**
     * Signs the user in with an identity provider. Note that even if User Sign-in is not
     * enabled in the project, the user is still signed-in with the Guest type provider.
     * @param signInProviderType provider type
     * @param completionHandler used to callback application with async operation results
     */
    func loginWithSignInProvider(signInProvider: AWSSignInProvider, completionHandler: @escaping (AnyObject?, NSError?) -> Void) {
        DispatchQueue.main.async {
            self.currentSignInProvider = signInProvider
            self.completionHandler = completionHandler
            self.currentSignInProvider?.login(completionHandler: completionHandler)
        }
    }
    
    /**
     * Attempts to resume session with the previous sign-in provider.
     * @param completionHandler used to callback application with async operation results
     */
    public func resumeSessionWithCompletionHandler(completionHandler: @escaping (AnyObject?, NSError?) -> Void) {
        self.completionHandler = completionHandler
        if let provider = self.currentSignInProvider {
            provider.reloadSession()
            if let _ = self.currentSignInProvider {
                self.completeLogin()
            }
        } else {
            print("No current SignIn Provider")
        }
    }
    func completeLogin() {
        // Force a refresh of credentials to see if we need to merge
        if let provider = self.credentialsProvider {
            provider.invalidateCachedTemporaryCredentials()
            provider.credentials().continueWith( block: { (task) -> Any? in
                DispatchQueue.main.async {
                    if let _ = self.currentSignInProvider {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AWSIdentityManager.DidSignInNotification), object: AWSIdentityManager.defaultIdentityManager(), userInfo: nil)
                    }
                    if let exception = task.exception {
                        print("AWS Identity Manager Fatal Exception in completingLogin")
                        print(exception)
                        kill(getpid(), SIGKILL)
                    }
                    
                }
            })
        }
    }
    /**
     * Passes parameters used to launch the application to the current identity provider. For some
     * third party providers, this completes the User Sign-in call flow, which used a browser to
     * get information from the user, directly. The current sign-in provider will be set to nil if
     * the sign-in provider is not registered using `registerAWSSignInProvider:forKey` method  of
     * `AWSSignInProviderFactory` class.
     * @param application application
     * @param launchOptions options used to launch the application
     * @return true if this call handled the operation
     */
    public func interceptApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let provider: AWSSignInProvider? = nil
        if let _ = UserDefaults.standard.object(forKey: "Facebook") {
            
        } else if let _ = UserDefaults.standard.object(forKey: "Google") {
            
        } else {
            print("In AWSIdentityManager, no Provider found")
        }
        self.currentSignInProvider = provider
        if let _ = provider {
            if self.currentSignInProvider == nil {
                print("Unable to locate the SignIn Provider SDK. Sigining out existing session...")
                self.wipeAll()
            }
        }
        if let provider = self.currentSignInProvider {
            return provider.interceptApplication(application: application, didFinishLaunchingWithOptions: launchOptions)
        } else {
            return true
        }
    }
    
    /**
     * Passes parameters used to launch the application to the current identity provider. For some
     * third party providers, this completes the User Sign-in call flow, which used a browser to
     * get information from the user, directly.
     * @param application application
     * @param url url used to open the application
     * @param sourceApplication source application
     * @param annotation annotation
     * @return true if this call handled the operation
     */
    public func interceptApplication(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let provider = self.currentSignInProvider {
            return provider.interceptApplication(application: application , openURL: url , sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return false
        }
        
    }
}
