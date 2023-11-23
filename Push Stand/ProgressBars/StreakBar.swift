//
//  SegmentedBar.swift
//  Test
//
//  Created by Tony Russell on 11/14/23.
//

import SwiftUI

struct StreakBar: View {
  var value: Int = 4
  var maximum: Int = 10
  var height: CGFloat = 18
  var spacing: CGFloat = 2
  var selectedColor: Color = .red
  var unselectedColor: Color = Color.secondary.opacity(0.1)
var body: some View {
    HStack(spacing: spacing) {
      ForEach(0 ..< 10) { index in
          Rectangle()
              .frame(width: 25.0)
          .foregroundColor(index < self.value ? self.selectedColor : self.unselectedColor)
      }

    }
    .frame(maxHeight: height)
    .clipShape(Capsule())
  }
}

#Preview {
    StreakBar()
}
