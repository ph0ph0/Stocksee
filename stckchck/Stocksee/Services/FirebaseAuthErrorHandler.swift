//
//  FirebaseAuthErrorHandlerFunc.swift
//  stckchck
//
//  Created by Pho on 31/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import Foundation
import FirebaseAuth

func fireErrorHandle(code: AuthErrorCode) {
    switch code {
    case .invalidCustomToken:
        print("deadBeef Indicates a validation error with the custom token")
    case .customTokenMismatch:
        print("deadBeef Indicates the service account and the API key belong to different projects")
    case .invalidCredential:
        print("deadBeef Indicates the IDP token or requestUri is invalid")
    case .userDisabled:
        print("deadBeef Indicates the user's account is disabled on the server")
    case .operationNotAllowed:
        print("deadBeef Indicates the administrator disabled sign in with the specified identity provider")
    case .emailAlreadyInUse:
        print("deadBeef Indicates the email used to attempt a sign up is already in use.")
    case .invalidEmail:
        print("deadBeef Indicates the email is invalid")
    case .wrongPassword:
        print("deadBeef Indicates the user attempted sign in with a wrong password")
    case .tooManyRequests:
        print("deadBeef Indicates that too many requests were made to a server method")
    case .userNotFound:
        print("deadBeef Indicates the user account was not found")
    case .accountExistsWithDifferentCredential:
        print("deadBeef Indicates account linking is required")
    case .requiresRecentLogin:
        print("deadBeef Indicates the user has attemped to change email or password more than 5 minutes after signing in")
    case .providerAlreadyLinked:
        print("deadBeef Indicates an attempt to link a provider to which the account is already linked")
    case .noSuchProvider:
        print("deadBeef Indicates an attempt to unlink a provider that is not linked")
    case .invalidUserToken:
        print("deadBeef Indicates user's saved auth credential is invalid, the user needs to sign in again")
    case .networkError:
        print("deadBeef Indicates a network error occurred (such as a timeout, interrupted connection, or unreachable host). These types of errors are often recoverable with a retry. The @cNSUnderlyingError field in the @c NSError.userInfo dictionary will contain the error encountered")
    case .userTokenExpired:
        print("deadBeef Indicates the saved token has expired, for example, the user may have changed account password on another device. The user needs to sign in again on the device that made this request")
    case .invalidAPIKey:
        print("deadBeef Indicates an invalid API key was supplied in the request")
    case .userMismatch:
        print("deadBeef Indicates that an attempt was made to reauthenticate with a user which is not the current user")
    case .credentialAlreadyInUse:
        print("deadBeef Indicates an attempt to link with a credential that has already been linked with a different Firebase account")
    case .weakPassword:
        print("deadBeef Indicates an attempt to set a password that is considered too weak")
    case .appNotAuthorized:
        print("deadBeef Indicates the App is not authorized to use Firebase Authentication with the provided API Key")
    case .keychainError:
        print("deadBeef Indicates an error occurred while attempting to access the keychain")
    default:
        print("deadBeef Indicates an internal error occurred")
    }
}

