//
//  NftInfo.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import SwiftUI

struct NftInfoSheet: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @Binding
    var nft: Nft
    
    @State
    var textForShare: String? = nil
    
    @State
    var showMinterInfo = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                SheetStroke()
                Spacer()
            }
            .padding(.bottom, 4)
            
            ScrollView {
                VStack(spacing: 0) {
                    Text("NFT")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-bold", size: 28))
                        .padding(.top, 26)
                    
                    VStack(spacing: 10) {
                        if let image = nft.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .background(Color.black)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, maxHeight: 325)
                            
                            Text(nft.data.name)
                                .foregroundColor(Colors.darkGrey)
                                .font(.custom("rubik-bold", size: 24))
                            
                            if let collection = nft.collectionName {
                                Text(collection.isEmpty ? "#Public collection" : "#\(collection)")
                                    .foregroundColor(Colors.mainGrey)
                                    .font(.custom("rubik-bold", size: 18))
                            }
                        } else {
                            MinterProgress()
                                .padding(100)
                        }
                    }
                    .padding(25)
                    .background(Colors.mainWhite)
                    .cornerRadius(10)
                    .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                    .padding(.horizontal, 26)
                    .padding(.top, 25)
                    .onAppear {
                        if nft.meta == nil {
                            var loadImageFromIpfs = false
                            if nft.image == nil && nft.data.filebaseName == nil {
                                loadImageFromIpfs = true
                            }
                            globalVm.loadNftMeta(nft: nft, loadImageAfter: loadImageFromIpfs)
                        }
                        if let filebaseName = nft.data.filebaseName, !filebaseName.isEmpty, nft.image == nil {
                            globalVm.loadImageFromFilebase(nft: nft)
                        }
                    }
                    
                    Button {
                        //TODO: unmock
                        if let url = URL(string: Tools.formOpenseaLink(contract: nft.contractAddress, tokenId: nft.tokenId)),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            //TODO: show error alert
                        }
                    } label: {
                        Text("Watch on the OpenSea")
                            .foregroundColor(Colors.mainPurple)
                            .font(.custom("rubik-bold", size: 17))
                            .padding(.top, 14)
                    }
                    
                    if let imageLink = nft.meta?.image {
                        Button {
                            if let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: imageLink)),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                //TODO: show error alert
                            }
                        } label: {
                            Text("Watch on the IPFS")
                                .foregroundColor(Colors.mainPurple)
                                .font(.custom("rubik-bold", size: 17))
                                .padding(.top, 10)
                        }
                    }
                    
                    Button {
                        globalVm.applyForRepostReward()
                        textForShare = "Some info to detect post\nhttps://opensea.io/assets/matic/0xba21ce6b4dc183fa5d257584e657b913c90a69da/12"
                    } label: {
                        Text("Share")
                            .font(.custom("rubik-bold", size: 17))
                            .foregroundColor(Colors.mainWhite)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 58)
                            .background(Colors.mainGradient)
                            .cornerRadius(32)
                            .padding(.top, 25)
                            .shadow(color: Colors.mainPurple.opacity(0.5), radius: 10, x: 0, y: 0)
                    }
                    .sheet(item: $textForShare,
                           onDismiss: { textForShare = nil }) { text in
                        ShareView(activityItems: [text])
                            .ignoresSafeArea()
                    }
                    
                    if globalVm.isRepostRewarded() {
                        Tip(text: "You can earn Minter Guru tokens by sharing photos on social networks")
                            .padding(.horizontal, 26)
                            .padding(.top, 25)
                        
                        Button {
                            showMinterInfo = true
                        } label: {
                            Text("More info")
                                .foregroundColor(Colors.mainPurple)
                                .font(.custom("rubik-bold", size: 16))
                        }
                        .padding(.vertical, 10)
                        .sheet(isPresented: $showMinterInfo) {
                            MinterInfoScreen()
                                .environmentObject(globalVm)
                        }
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

