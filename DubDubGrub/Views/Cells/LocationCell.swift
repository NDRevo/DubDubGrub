//
//  LocationCell.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

struct LocationCell: View {
    
    var location: DDGLocation
    
    var body: some View {
        HStack {
            Image(uiImage: location.createSquareImage())
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(.vertical, 8)
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                HStack {
                    AvatarView(size: 35,image: PlaceholderImage.avatar)
                    AvatarView(size: 35,image: PlaceholderImage.avatar)
                    AvatarView(size: 35,image: PlaceholderImage.avatar)
                }
            }
            .padding(.leading)
        }
    }
}

struct LocationCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationCell(location: DDGLocation(record: MockData.location))
    }
}
