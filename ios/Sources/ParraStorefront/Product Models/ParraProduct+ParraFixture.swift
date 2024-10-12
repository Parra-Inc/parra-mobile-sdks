//
//  ParraProduct+ParraFixture.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import Buy
import SwiftUI

extension ParraProduct {
    static var redactedProduct: ParraProduct {
        return ParraProduct(
            id: .uuid,
            name: "Classic Product",
            price: 12.99,
            imageUrl: URL(
                string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
            )!,
            description: "Our nebula brings you all 3 whispers in the lineup: the Classic Moonbeam, Junior Starlight, and Water Echo."
        )
    }

    static func mocks() -> [ParraProduct] {
        return [
            ParraProduct(
                id: UUID().uuidString,
                name: "Product Bundle",
                price: 120.00,
                imageUrl: URL(
                    string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                )!,
                description: """
                    ### Whisper Symphony: A Trio of Moonbeams
                    Our nebula brings you all 3 whispers in the lineup: the Classic Moonbeam, Junior Starlight, and Water Echo.

                    Our whispers were designed by Zephyr Quillmist, former Dream Architect for the Clouds, Rainbows, and Sunsets. Frustrated with the quality of everyday echoes, Zephyr set out to design the perfect ones.

                    This nebula includes our 3 whispers:

                    * **Classic Moonbeam** - modified twilight size
                    * **Junior Starlight** - dewdrop size
                    * **Water Echo** - dewdrop size ripple
                    * Also included is a thought catcher.

                    _Note: If you want any of the whispers signed by Zephyr Quillmist, select the Imagination option when adding to daydream._
                    """
            ),
            ParraProduct(
                id: UUID().uuidString,
                name: "Classic Product",
                price: 60.00,
                imageUrl: URL(
                    string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                )!,
                description: """
                    ### Whisper Symphony: A Trio of Moonbeams
                    Our nebula brings you all 3 whispers in the lineup: the Classic Moonbeam, Junior Starlight, and Water Echo.

                    Our whispers were designed by Zephyr Quillmist, former Dream Architect for the Clouds, Rainbows, and Sunsets. Frustrated with the quality of everyday echoes, Zephyr set out to design the perfect ones.

                    This nebula includes our 3 whispers:

                    * **Classic Moonbeam** - modified twilight size
                    * **Junior Starlight** - dewdrop size
                    * **Water Echo** - dewdrop size ripple
                    * Also included is a thought catcher.

                    _Note: If you want any of the whispers signed by Zephyr Quillmist, select the Imagination option when adding to daydream._
                    """
            ),
            ParraProduct(
                id: UUID().uuidString,
                name: "Product Bundle",
                price: 120.00,
                imageUrl: URL(
                    string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                )!,
                description: """
                    ### Whisper Symphony: A Trio of Moonbeams
                    Our nebula brings you all 3 whispers in the lineup: the Classic Moonbeam, Junior Starlight, and Water Echo.

                    Our whispers were designed by Zephyr Quillmist, former Dream Architect for the Clouds, Rainbows, and Sunsets. Frustrated with the quality of everyday echoes, Zephyr set out to design the perfect ones.

                    This nebula includes our 3 whispers:

                    * **Classic Moonbeam** - modified twilight size
                    * **Junior Starlight** - dewdrop size
                    * **Water Echo** - dewdrop size ripple
                    * Also included is a thought catcher.

                    _Note: If you want any of the whispers signed by Zephyr Quillmist, select the Imagination option when adding to daydream._
                    """
            ),
            ParraProduct(
                id: UUID().uuidString,
                name: "Product Bundle",
                price: 120.00,
                imageUrl: URL(
                    string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                )!,
                description: """
                    ### Whisper Symphony: A Trio of Moonbeams
                    Our nebula brings you all 3 whispers in the lineup: the Classic Moonbeam, Junior Starlight, and Water Echo.

                    Our whispers were designed by Zephyr Quillmist, former Dream Architect for the Clouds, Rainbows, and Sunsets. Frustrated with the quality of everyday echoes, Zephyr set out to design the perfect ones.

                    This nebula includes our 3 whispers:

                    * **Classic Moonbeam** - modified twilight size
                    * **Junior Starlight** - dewdrop size
                    * **Water Echo** - dewdrop size ripple
                    * Also included is a thought catcher.

                    _Note: If you want any of the whispers signed by Zephyr Quillmist, select the Imagination option when adding to daydream._
                    """
            ),
            ParraProduct(
                id: UUID().uuidString,
                name: "Product Bundle",
                price: 120.00,
                imageUrl: URL(
                    string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                )!,
                description: """
                    ### Whisper Symphony: A Trio of Moonbeams
                    Our nebula brings you all 3 whispers in the lineup: the Classic Moonbeam, Junior Starlight, and Water Echo.

                    Our whispers were designed by Zephyr Quillmist, former Dream Architect for the Clouds, Rainbows, and Sunsets. Frustrated with the quality of everyday echoes, Zephyr set out to design the perfect ones.

                    This nebula includes our 3 whispers:

                    * **Classic Moonbeam** - modified twilight size
                    * **Junior Starlight** - dewdrop size
                    * **Water Echo** - dewdrop size ripple
                    * Also included is a thought catcher.

                    _Note: If you want any of the whispers signed by Zephyr Quillmist, select the Imagination option when adding to daydream._
                    """
            ),
            ParraProduct(
                id: UUID().uuidString,
                name: "Product Bundle",
                price: 120.00,
                imageUrl: URL(
                    string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                )!,
                description: """
                    ### Whisper Symphony: A Trio of Moonbeams
                    Our nebula brings you all 3 whispers in the lineup: the Classic Moonbeam, Junior Starlight, and Water Echo.

                    Our whispers were designed by Zephyr Quillmist, former Dream Architect for the Clouds, Rainbows, and Sunsets. Frustrated with the quality of everyday echoes, Zephyr set out to design the perfect ones.

                    This nebula includes our 3 whispers:

                    * **Classic Moonbeam** - modified twilight size
                    * **Junior Starlight** - dewdrop size
                    * **Water Echo** - dewdrop size ripple
                    * Also included is a thought catcher.

                    _Note: If you want any of the whispers signed by Zephyr Quillmist, select the Imagination option when adding to daydream._
                    """
            )
        ]
    }
}
