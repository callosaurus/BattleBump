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
    func session(session: MCSession, wasInterruptedByState state: MCSessionState)
}

protocol MPCJoiningProtocol: NSObjectProtocol {
    func didChangeFoundHosts()
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    weak var delegate: MPCManagerProtocol?
    weak var joinDelegate: MPCJoiningProtocol?
    
    var myPeerID : MCPeerID?
    var myAdvertiser : MCNearbyServiceAdvertiser?
    var myBrowser : MCNearbyServiceBrowser?
    var mySession : MCSession?
    
    var foundHostsArray = [Host]()
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer [\(peerID.displayName)] changed state to \(string(forPeerConnectionState: state))")
        
        if (state == .notConnected) {
            self.delegate?.session(session: session, wasInterruptedByState: state)
        }
        //        else if (state == .connected) {
        //            self.delegate?.didConnectSuccessfully()
        //        }
    }
    
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
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // MCSession Delegate callback when receiving data from a peer in a given session
        print("Received data from \(peerID.displayName)")
        let dictionary: [AnyHashable: Any]? = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable : Any]
        let invitee = dictionary?["invitee"]
        delegate?.receivedInviteeMessage(invitee as! Invitee)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // MCSession delegate callback when we start to receive a resource from a peer in a given session
        print("Start receiving resource [\(resourceName)] from peer \(peerID.displayName) with progress [\(progress)]")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        // MCSession delegate callback when a incoming resource transfer ends (possibly with error)
        print("Received data over resource with name \(resourceName) from peer \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Streaming API not utilized in this sample code
        print("Received data over stream with name \(streamName) from peer \(peerID.displayName)")
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate -
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mySession)
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate -
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("Found peer: \(peerID.displayName)")
        
        let hostFound = Host(name: peerID.displayName, emoji: (info?["emoji"])!)
        
        if (!self.foundHostsArray.contains(hostFound)) {
            self.foundHostsArray.append(hostFound)
        }
        //eventually have moveset in discoveryInfo
        
        self.joinDelegate?.didChangeFoundHosts()
        
        //        self.mySession = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .none)
        //        self.mySession.delegate = self
        //        browser.invitePeer(peerID, to: self.mySession, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer lost: \(peerID.displayName)")
        
        //removes lost Host
        if let lostHost = self.foundHostsArray.first(where: { $0.name == peerID.displayName }) {
            if let index = self.foundHostsArray.index(of: lostHost) {
                self.foundHostsArray.remove(at: index)
            }
        }
        
        self.joinDelegate?.didChangeFoundHosts()
        
    }
    
    //MARK: -  MPCManager Client Methods -
    
    func advertiseToPeers(invitee: Invitee) {
        
        if (self.myPeerID == nil) {
            self.myPeerID = MCPeerID(displayName: invitee.player.name)
            print(String(format:"Making new peerID to advertise: %@", self.myPeerID!))
        }
        
        let dict = ["emoji": invitee.player.emoji]
        // eventually have discoveryInfo containing moveset name and moves
        
        self.myAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID!, discoveryInfo: dict, serviceType: "RPSgame")
        print("Advertising for \(String(describing: myPeerID))")
        
        self.myAdvertiser?.delegate = self
        self.myAdvertiser?.startAdvertisingPeer()
    }
    
    func findPeers(invitee : Invitee) {
        if (self.myPeerID == nil) {
            self.myPeerID = MCPeerID(displayName: invitee.player.name)
            print(String(format:"Making new peerID to browse with: %@", self.myPeerID!))
        }
        
        self.myBrowser = MCNearbyServiceBrowser(peer: myPeerID!, serviceType: "RPSgame")
        print("Browsing with \(String(describing: myPeerID))")
        
        self.myBrowser?.delegate = self
        self.myBrowser?.startBrowsingForPeers()
    }
    
    func joinPeer(peerID: MCPeerID) {
        self.myBrowser?.invitePeer(peerID, to: self.mySession!, withContext: nil, timeout: 10)
    }
    
    //    func checkConnectedPeers() {
    //
    //    }
    
    func send(_ invitee: Invitee) {
        
        print("Send Invitee Message\n")
        let dictionary = ["invitee": invitee]
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        
        do {
            try self.mySession?.send(data, toPeers: (self.mySession?.connectedPeers)!, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
}
