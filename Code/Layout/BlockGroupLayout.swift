/*
* Copyright 2015 Google Inc. All Rights Reserved.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/**
Stores information on how to render and position a group of sequential `Block` objects (ie. those
that are connecting via previous/next connections).
*/
@objc(BKYBlockGroupLayout)
public class BlockGroupLayout: Layout {
  // MARK: - Properties

  /*
  A list of sequential block layouts that belong to this group. While this class doesn't enforce
  it, the following should hold true:

  1) When `i < blockLayouts.count - 1`:

  `blockLayouts[i].block.nextBlock = blockLayouts[i + 1].block`

  2) When `i >= 1`:

 `blockLayouts[i].block.previousBlock = blockLayouts[i - 1].block`
  */
  public private(set) var blockLayouts = [BlockLayout]()

  // MARK: - Initializers

  public override init(parentLayout: Layout?) {
    super.init(parentLayout: parentLayout)
  }

  // MARK: - Super

  public override var childLayouts: [Layout] {
    return blockLayouts
  }

  public override func layoutChildren() {
    var yOffset: CGFloat = 0

    // Update relative position/size of inputs
    for blockLayout in blockLayouts {
      blockLayout.layoutChildren()

      blockLayout.relativePosition.x = 0
      blockLayout.relativePosition.y = yOffset

      // TODO:(vicng) Blocks are technically overlapping. Take into account the size of the notch
      // to figure out how much each block should actually be offset by.
      yOffset += blockLayout.size.height
    }

    // Update the size required for this block
    self.size = sizeThatFitsForChildLayouts()
  }

  // MARK: - Public

  /**
  Appends a blockLayout to `self.blockLayouts` and sets its `parentLayout` to this instance.

  - Parameter blockLayout: The `BlockLayout` to append.
  */
  public func appendBlockLayout(blockLayout: BlockLayout) {
    blockLayout.parentLayout = self
    blockLayouts.append(blockLayout)
  }

  /**
  Removes `self.blockLayouts[index]`, sets its `parentLayout` to nil, and returns it.

  - Parameter index: The index to remove from `self.blockLayouts`.
  - Returns: The `BlockLayout` that was removed.
  */
  public func removeBlockLayoutAtIndex(index: Int) -> BlockLayout {
    let blockLayout = blockLayouts.removeAtIndex(index)
    blockLayout.parentLayout = nil
    return blockLayout
  }
}
