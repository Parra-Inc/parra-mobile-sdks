//
//  Storefront+productQueries.swift
//  Parra
//
//  Created by Mick MacCallum on 10/3/24.
//

import Buy
import Parra

extension Storefront.QueryRootQuery {
    static func productsQuery(
        count: Int32 = 50,
        startCursor: String? = nil,
        endCursor: String? = nil,
        sortKey: Storefront.ProductSortKeys? = nil
    ) -> Storefront.QueryRootQuery {
        return Storefront.buildQuery { $0
            .products(
                first: count,
                after: startCursor,
                before: endCursor,
                sortKey: sortKey
            ) { products in
                appendProductFields(to: products)
            }
        }
    }

    @discardableResult
    private static func appendProductFields(
        to products: Storefront.ProductConnectionQuery
    ) -> Storefront.ProductConnectionQuery {
        return products
            .pageInfo { $0
                .hasNextPage()
                .startCursor()
                .endCursor()
            }
            .edges { $0
                .node { $0
                    .id()
                    .description()
                    .title()
                    .availableForSale()
                    .createdAt()
                    .descriptionHtml()
                    .featuredImage { $0
                        .id()
                        .altText()
                        .height()
                        .width()
                        .url()
                    }
                    .images(first: 25) { $0
                        .nodes { $0
                            .id()
                            .altText()
                            .height()
                            .width()
                            .url()
                        }
                    }
                    .onlineStoreUrl()
                    .publishedAt()
                    .requiresSellingPlan()
                    .tags()
                    .totalInventory()
                    .options { $0
                        .id()
                        .name()
                        .optionValues { $0
                            .id()
                            .name()
                        }
                    }
                    .variants(first: 10) { $0
                        .nodes { $0
                            .availableForSale()
                            .currentlyNotInStock()
                            .id()
                            .quantityAvailable()
                            .title()
                            .price { $0
                                .amount()
                                .currencyCode()
                            }
                            .compareAtPrice { $0
                                .amount()
                                .currencyCode()
                            }
                        }
                    }
                    .priceRange { $0
                        .maxVariantPrice { $0
                            .amount()
                            .currencyCode()
                        }
                        .minVariantPrice { $0
                            .amount()
                            .currencyCode()
                        }
                    }
                    .compareAtPriceRange { $0
                        .maxVariantPrice { $0
                            .amount()
                            .currencyCode()
                        }
                        .minVariantPrice { $0
                            .amount()
                            .currencyCode()
                        }
                    }
                }
            }
    }
}
