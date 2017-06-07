//
//  MPCManager.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCManagerProtocol: NSObjectProtocol {
    func receivedInviteeMessage(_ invitee: Invitee)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    weak var delegate: BBNetworkManagerProtocol?
    
//    var myPeerID = MCPeerID()
    var myAdvertiser = MCNearbyServiceAdvertiser()
    var myBrowser = MCNearbyServiceBrowser()
    var mySession = MCSession()
    
    func string(forPeerConnectionState state: MCSessionState) -> String {
        switch state {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .notConnected:
            return "Not Connected"
        }
    }
    // Override this method to handle changes to peer session state
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer [\(peerID.displayName)] changed state to \(string(forPeerConnectionState: state))")
//        OperationQueue.main.addOperation {() -> Void in
//            // send current connection state to Connect VC
//        }
    }
    // MCSession Delegate callback when receiving data from a peer in a given session
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received data from \(peerID.displayName)")
        let dictionary: [AnyHashable: Any]? = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable : Any]
        let invitee = dictionary?["invitee"]
        delegate?.receivedInviteeMessage(invitee as! Invitee)
    }
    
    // MCSession delegate callback when we start to receive a resource from a peer in a given session
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Start receiving resource [\(resourceName)] from peer \(peerID.displayName) with progress [\(progress)]")
    }
    
    // MCSession delegate callback when a incoming resource transfer ends (possibly with error)
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("Received data over resource with name \(resourceName) from peer \(peerID.displayName)")
    }
    
    // Streaming API not utilized in this sample code
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received data over stream with name \(streamName) from peer \(peerID.displayName)")
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate -
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mySession)
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate -
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer lost: \(peerID.displayName)")
    }
    
    //MARK: - BBNetwork Manager Client Methods
    
    func findPeers() {
        let myPeerID = MCPeerID(displayName: <#T##String#>)
        
    }
    
    func join(with invitee: Invitee) {
        //        mySession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        //        mySession.delegate = self
        //        browser.invitePeer(peerID, to: mySession, withContext: nil, timeout: 10)
        
    }
    func send(_ invitee: Invitee) {
        
    }
    
}
