//
//  Storefront+cartMutationQueries.swift
//  Parra
//
//  Created by Mick MacCallum on 10/3/24.
//

import Buy
import Parra

extension Storefront.MutationQuery {
    static func createCartMutation(
        for input: Storefront.CartInput
    ) -> Storefront.MutationQuery {
        return Storefront.buildMutation { $0
            .cartCreate(
                input: input
            ) { $0
                .cart { cart in
                    appendCartFields(to: cart)
                }
            }
        }
    }

    static func updateNoteCartMutation(
        for cartId: String,
        note: String?
    ) -> Storefront.MutationQuery {
        return Storefront.buildMutation { $0
            .cartNoteUpdate(
                cartId: .init(rawValue: cartId),
                note: note ?? ""
            ) { $0
                .cart { cart in
                    appendCartFields(to: cart)
                }
            }
        }
    }

    static func updateLineItemQuantityCartMutation(
        lineItemId: String,
        cartId: String,
        quantity: UInt
    ) -> Storefront.MutationQuery {
        let lines: [Storefront.CartLineUpdateInput] = [
            .create(
                id: .init(rawValue: lineItemId),
                quantity: .value(Int32(quantity))
            )
        ]

        return Storefront.buildMutation { $0
            .cartLinesUpdate(
                cartId: .init(rawValue: cartId),
                lines: lines
            ) { $0
                .cart { cart in
                    appendCartFields(to: cart)
                }
            }
        }
    }

    static func addToCartCartMutation(
        cartId: String,
        productVariant: ParraProductVariant,
        quantity: UInt
    ) -> Storefront.MutationQuery {
        let lines: [Storefront.CartLineInput] = [
            .create(
                merchandiseId: .init(rawValue: productVariant.id),
                quantity: .value(Int32(quantity))
            )
        ]

        return Storefront.buildMutation { $0
            .cartLinesAdd(
                lines: lines,
                cartId: GraphQL.ID(rawValue: cartId)
            ) { $0
                .cart { cart in
                    appendCartFields(to: cart)
                }
            }
        }
    }

    static func removeLineItemCartMutation(
        lineItemId: String,
        cartId: String
    ) -> Storefront.MutationQuery {
        return Storefront.buildMutation { $0
            .cartLinesRemove(
                cartId: .init(rawValue: cartId),
                lineIds: [.init(rawValue: lineItemId)]
            ) { $0
                .cart { cart in
                    appendCartFields(to: cart)
                }
            }
        }
    }

    @discardableResult
    private static func appendCartFields(
        to cart: Storefront.CartQuery
    ) -> Storefront.CartQuery {
        return cart
            .id()
            .checkoutUrl()
            .totalQuantity()
            .cost { $0
                .subtotalAmount { $0
                    .amount()
                    .currencyCode()
                }
                .totalAmount { $0
                    .amount()
                    .currencyCode()
                }
            }
            .note()
            .lines(first: 100) { $0
                .edges { $0
                    .node { $0
                        .id()
                        .quantity()
                        .discountAllocations { $0
                            .discountedAmount { $0
                                .amount()
                                .currencyCode()
                            }
                            .onCartAutomaticDiscountAllocation { $0
                                .discountedAmount { $0
                                    .amount()
                                    .currencyCode()
                                }
                                .title()
                                .targetType()
                            }
                        }
                        .cost { $0
                            .subtotalAmount { $0
                                .amount()
                                .currencyCode()
                            }
                            .totalAmount { $0
                                .amount()
                                .currencyCode()
                            }
                            .amountPerQuantity { $0
                                .amount()
                                .currencyCode()
                            }
                            .compareAtAmountPerQuantity { $0
                                .amount()
                                .currencyCode()
                            }
                        }
                        .merchandise { $0
                            .onProductVariant { $0
                                .id()
                                .title()
                                .product { $0
                                    .id()
                                    .title()
                                    .featuredImage { $0
                                        .id()
                                        .url()
                                        .width()
                                        .height()
                                        .altText()
                                    }
                                }
                                .selectedOptions { $0
                                    .name()
                                    .value()
                                }
                                .quantityAvailable()
                                .image { $0
                                    .id()
                                    .height()
                                    .width()
                                    .url()
                                    .altText()
                                }
                                .price { $0
                                    .amount()
                                    .currencyCode()
                                }
                            }
                        }
                    }
                }
            }
    }
}
