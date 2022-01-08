//
//  LocationCell.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/1/21.
//

import SwiftUI

struct LocationCell: View {
    
    var location: DDGLocation
    var profiles: [DDGProfile]
    
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
                    .minimumScaleFactor(0.75)
                if profiles.isEmpty {
                    Text("No one is checked")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                } else {
                    HStack {
                        ForEach(profiles.indices, id: \.self){ index in
                            if index <= 3 {
                                AvatarView(size: 35, image: profiles[index].createAvatarImage())
                            } else if index == 4 {
                                AdditionalProfilesView(number: profiles.count - 4)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LocationCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationCell(location: DDGLocation(record: MockData.location), profiles: [])
    }
}

struct AdditionalProfilesView: View {

    var number: Int

    var body: some View {
        Text("+\(number)")
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 35, height: 35)
            .foregroundColor(.white)
            .background(Color.brandPrimary)
            .clipShape(Circle())
    }
}
