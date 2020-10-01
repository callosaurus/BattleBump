//
//  MPCManager.swift
//  BattleBump
//
//  Created by Callum Davies on 2017-06-06.
//  Copyright © 2017 Callum Davies & Dave Augerinos. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCManagerProtocol: NSObjectProtocol {
    func receivedPlayerDataFromPeer(_ player: Player)
    func session(session: MCSession, wasInterruptedByState state: MCSessionState)
    func didChangeFoundPeers()
    func didConnectSuccessfullyToPeer()
}
// unused functions in GameViewController, but power to handle disconnects in each class?


class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    weak var managerDelegate: MPCManagerProtocol?
    
    var myPeerID = MCPeerID(displayName: UIDevice.current.name)
    var myAdvertiser : MCNearbyServiceAdvertiser?
    var myBrowser : MCNearbyServiceBrowser?
    var mySession : MCSession?
    
    var foundPeersArray = [MCPeerID]()
    var connectedPlayersDictionary = [MCPeerID:Player]()
    
    // MARK: - MCSessionDelegate -
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer [\(peerID.displayName)] changed state to \(string(forPeerConnectionState: state))")
        
        if (state == .connected) {
            print("I am \((myPeerID.displayName)). I am connected to \(peerID.displayName)")
            print(session.connectedPeers)
            
            managerDelegate?.didConnectSuccessfullyToPeer()
            
        } else if (state == .notConnected) {
            foundPeersArray = []
            managerDelegate?.session(session: session, wasInterruptedByState: state)
        }
    }
    
    func string(forPeerConnectionState state: MCSessionState) -> String {
        switch state {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .notConnected:
            return "Not Connected"
        @unknown default:
            return "Unknown State"
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // MCSession Delegate callback when receiving data from a peer in a given session
        print("Received data from \(peerID.displayName)")
        
//        guard let player = NSKeyedUnarchiver.unarchiveObject(with: data) as? Player else {
//            print("Could not decode invitee properly")
//            return
//        }
        
        do {
            let player = try JSONDecoder().decode(Player.self, from: data)
            managerDelegate?.receivedPlayerDataFromPeer(player)
        } catch {
            print(error.localizedDescription)
            print("Could not decode player properly")
        }
        
        //still have to unarchive data or .JSONdecode
        
        //receivedPlayerDataFromPeer() as above?
    }
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // MCSession delegate callback when we start to receive a resource from a peer in a given session
        print("Start receiving resource [\(resourceName)] from peer \(peerID.displayName) with progress [\(progress)]")
    }
    
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // MCSession delegate callback when a incoming resource transfer ends (possibly with error)
        print("Received data over resource with name \(resourceName) from peer \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Streaming API not utilized in this sample code
        print("Received data over stream with name \(streamName) from peer \(peerID.displayName)")
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate -
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        if (mySession == nil) {
            mySession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
            mySession?.delegate = self
            invitationHandler(true, mySession)
        }
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate -
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("Found peer: \(peerID)")
        
        //        let newHostPlayerFound = Host(hostPeerID: peerID, emoji: (info?["emoji"])!)
        
        //        let playerName = peerID.displayName.components(separatedBy: ":")[0]
        //        let newHostPlayerFound = Player(name: playerName, peerID: peerID)
        if (!foundPeersArray.contains(peerID)) {
            foundPeersArray.append(peerID)
        }
        
        //eventually have moveset in discoveryInfo, decode
        myBrowser?.stopBrowsingForPeers()
        managerDelegate?.didChangeFoundPeers()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer lost: \(peerID.displayName)")
        
        if let indexOfLostHost = foundPeersArray.firstIndex(of: peerID) {
            foundPeersArray.remove(at: indexOfLostHost)
        } else {
            print("Peer wasn't removed")
        }
        
        //removes lost Host
//        if let lostHost = foundPlayersDictionary.first(where: { $0.peerID == peerID }) {
//            if let index = foundPlayersDictionary.firstIndex(of: lostHost) {
//                foundPlayersDictionary.remove(at: index)
//            }
//        }
        managerDelegate?.didChangeFoundPeers()
    }
    
    //MARK: -  MPCManager Client Methods -
    
    func advertiseToPeers() {
        
        // TODO: add chosen moveset name to discoveryInfo
        let dict = ["testKey":"testValue"]
        myAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo:dict, serviceType: "RPSgame")
        print("Advertising for \(myPeerID.displayName))")
        
        myAdvertiser?.delegate = self
        myAdvertiser?.startAdvertisingPeer()
    }
    
    
    func findPeers() {
        myBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "RPSgame")
        print("Browsing with \(myPeerID.displayName))")
        
        myBrowser?.delegate = self
        myBrowser?.startBrowsingForPeers()
    }
    
    
    func joinPeer(peerID: MCPeerID) {
        
        if (myPeerID != nil && myBrowser != nil) {
            print("Connecting to: \(peerID)")
            mySession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
            mySession?.delegate = self
            myBrowser?.invitePeer(peerID, to: mySession!, withContext: nil, timeout: 10)
        }
    }
    
    
    func send(_ player: Player) {
        
        print("Sending Player Update...")
        //        let dictionary = ["invitee": invitee]
        //        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        
        /// JSON encode instead of archive?
//        let data = NSKeyedArchiver.archivedData(withRootObject: player)

        
        do {
            let data = try JSONEncoder().encode(player)
            try mySession?.send(data, toPeers: (mySession?.connectedPeers)!, with: .reliable)
        } catch {
            print(error.localizedDescription)
            print("Could not send player update properly")
        }
        
//        do {
//            try mySession?.send(data, toPeers: (mySession?.connectedPeers)!, with: .reliable)
//        } catch {
//            print(error.localizedDescription)
//            print("Could not send player update properly")
//        }
        
    }
    
}
