//
//  OrderStatusEnum.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 26.06.23.
//

import Foundation

enum OrderStatus: String {
    case paymentPending = "paymentPending"
    case processing = "processing"
    case completed = "completed"
    case cancelled = "cancelled"
}
