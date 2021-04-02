//
//  AddComment+CollectionDelegate.swift
//  RapSheet
//
//  Created by DREAMWORLD on 27/02/21.
//  Copyright © 2021 Kalpesh Satasiya. All rights reserved.
//

import Foundation
import UIKit

extension AddCommentScreenViewController :UICollectionViewDelegate,UICollectionViewDataSource  {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrComments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.className, for: indexPath) as? CommentCell {
            
            ConfigureCommentCell(cell: cell, indexpath: indexPath)
            
            return cell
        }
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 250, height: 30)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(indexPath.row)
        
        if arrName.contains(arrComments[indexPath.row]) {
            arrName = arrName.filter { $0 != arrComments[indexPath.row] }
        }else {
            arrName.append(arrComments[indexPath.row])
        }
        
        print("arrName -------------------------  \(arrName)")
        collectionComment.reloadData()
    }
        
        
    //MARK:- Configure cell
    
    func ConfigureCommentCell(cell:CommentCell,indexpath:IndexPath) {
        let data = arrComments[indexpath.row]
        cell.lblCommentName.text = data
        cell.lblCommentName.preferredMaxLayoutWidth = collectionComment.frame.width - 32
        self.collectionCommentHeight.constant = self.collectionComment.contentSize.height
        
        if arrName.contains(arrComments[indexpath.row]) {
            cell.viewName.backgroundColor = BACKGROUND_COLOR
            cell.lblCommentName.textColor = APP_WHITE_COLOR
        }else{
            cell.viewName.backgroundColor = APP_WHITE_COLOR
            cell.lblCommentName.textColor = LABEL_COLOR
        }
        
        
    }
    
}

